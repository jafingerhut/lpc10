#include <unistd.h>
#include <fcntl.h>
#include <stropts.h>
#include <errno.h>
#include <values.h>
#include "abplay.h"
#include <multimedia/libaudio.h>
#include <multimedia/audio_device.h>
#include <xview/notify.h>

#define AUDIO_DEV	"/dev/audio"
#define AUDIO_CTLDEV	"/dev/audioctl"

static int device_fd = 0;	/* Audio device fd */
static int devctl_fd = 0;	/* Audioctl device fd (for status changes) */
#define SIG_SIZE 	4096	/* Audio output buffer size (>= STEPMAX!) */
static char ptbuf[SIG_SIZE];	/* Signal translation buffer */
static int event_posted = FALSE; /* Synchronous notifier client called */

static struct {		/* State of background audio stream */
	int state;	/* IDLE, DRAIN, or PLAY */
	int id;		/* ID of currently (or most recently) playing data */
	char *segstart;	/* Pointer to beginning of segment */
	char *segend;	/* Pointer to end of segment */
	char *posn;	/* Current I/O location in signal file */
	char *bp;	/* Current I/O location in translation buffer */
	int nb;		/* Unsent bytes left in translation buffer */
	int trans;	/* Audio file translation code */
	int nmax;	/* Max input to avoid translation buffer overflow */
} audio;

static struct {
	int id;		/* File ID of request (-1 if none) */
	float start;	/* Starting point of segment (seconds) */
	float end;	/* Ending point of segment */
} request;

Notify_value sigpoll_handler();

abp_open_device(int dtype)
{
	int flags;
	char *dev = AUDIO_DEV;

	if (device_fd <= 0) {
	    audio.state = IDLE;
	    if ((device_fd = open(dev, O_WRONLY | O_NDELAY)) < 0) {
	        perror(dev);
	        if ((errno==EINTR) || (errno==EBUSY)) device_fd = -2;
	    } else {
	        flags = fcntl(device_fd, F_GETFL, 0) | O_NONBLOCK;
	        if (fcntl(device_fd, F_SETFL, flags) < 0)
	            perror("audio device F_SETFL fcntl"); /* Set non-blocking */
	        if (ioctl(device_fd, I_SETSIG, S_OUTPUT | S_MSG) < 0)
	            perror("audio device I_SETSIG");	/*Enable play SIGPOLL*/

	        if ((devctl_fd = open(AUDIO_CTLDEV, O_RDWR)) < 0)
	            perror(AUDIO_CTLDEV);
	        if (ioctl(devctl_fd, I_SETSIG, S_MSG) < 0)
	            perror("audio_ctl I_SETSIG");   /* Enable status SIGPOLL */

         /* Set up to catch SIGPOLL asynchronously to service audio stream  */
         /* Notifier client id is meaningless, but must be unique, so use the
              virtual memory address of something random that we own.       */
	        (void) notify_set_signal_func((int)&audio,
	            (Notify_func)sigpoll_handler, SIGPOLL, NOTIFY_ASYNC);
	    }
	}
	return device_fd;	/* -1 = error, -2 = try again */
}

abp_close_device()
{
	if (device_fd > 0) close(device_fd);
	if (devctl_fd > 0) close(devctl_fd);
	device_fd = devctl_fd = 0;
}

abp_start_play(int id, int segnum)
{
	struct segstate sg;

	if (abp_open_device(0) < 0) return;
	sg = abp_get_segstate();
	request.id = id;
	request.start = request.end = 0.0;
	if (segnum > 0 && segnum <= sg.nsegs) {
	    request.start = sg.segs[segnum-1].start;
	    request.end   = sg.segs[segnum-1].end;
	}
	audio.state = DRAIN;
	kill(getpid(), SIGPOLL);	/* kick SIGPOLL to start play */
}

abp_stop_play()
{
	audio.state = DRAIN;
	audio_play_eof(device_fd);   /* EOF will SIGPOLL after buffer drains */
}

abp_abort_play()
{
	audio.state = DRAIN;
	audio_flush_play(device_fd);
	kill(getpid(), SIGPOLL);	/* Quit immediately */
}

abp_get_audio_status(struct audio_status *status)
{
	status->id = audio.id;
	status->state = audio.state;
	event_posted = FALSE;
}

/************************* End of public interface *********************/
/*********************** The rest is implementation ********************/

play_setup()
{
	int i;
	int id, n1, n2;
	struct abfile *abf;
	Audio_hdr dev_hdr, f_hdr;
	char *base;

	id = request.id;
	request.id = -1;
	if ((abf = abp_get_abfile(id)) == (struct abfile *)0) {
	    fprintf(stderr, "play: invalid file (%d)\n", id);
	    return -1;
	}
	f_hdr = abf->h;
	if (request.end <= 0.0) {
	    n1 = 0;
	    n2 = MAXINT;
	} else {
	    n1 = audio_secs_to_bytes(&f_hdr, request.start + abf->p.delay);
	    n2 = audio_secs_to_bytes(&f_hdr, request.end + abf->p.delay) - 1;
	}
	if (n1 >= n2) return -1;

	audio.trans = audio_set_play_translate(device_fd, &f_hdr, &dev_hdr);
	if (audio.trans >= 0) {
	    audio.state = PLAY;
	    audio.nb = 0;
	    audio.id = id;
	    base = abf->data + abf->hsize;
	    audio.segstart = base + MAX(0, n1);
	    audio.segend  =  base + MIN(f_hdr.data_size-1, n2);
	    audio.posn = audio.segstart;
	    audio.nmax = (SIG_SIZE * f_hdr.bytes_per_unit) /
	                            dev_hdr.bytes_per_unit;
	}
	return audio.trans;
}

play_service()
{
	int outcnt, n;

	outcnt = audio.segend + 1 - audio.posn;
	while (outcnt > 0 || audio.nb > 0) {
	   if (audio.nb == 0) {
	      if (audio.trans == 0) {
	         audio.bp = audio.posn;
	         audio.nb = n = outcnt;
	      } else {
	         audio.bp = ptbuf;
	         n = MIN(outcnt, audio.nmax);
	         audio.nb = audio_translate(audio.trans, audio.posn, ptbuf, n);
	      }
	      audio.posn += n;
	      outcnt -= n;
	   }
	   n = write(device_fd, audio.bp, audio.nb);
	   if (n < 0 && errno != EWOULDBLOCK) {
	      perror("audio device write err");
	      audio_flush_play(device_fd);
	   }
	   if (n <= 0) break;
	   audio.nb -= n;
	   audio.bp += n;

	   if (outcnt == 0 && audio.nb == 0) abp_stop_play();
	}
}

/* Asynchronous SIGPOLL handler.  Service audio device */
Notify_value
sigpoll_handler(Notify_client client, int sig, Notify_signal_mode when)
{
	int n;
	unsigned active = 0;
	static char *sttr[] = {"IDLE", "DRAIN", "PLAY"};

/*	fprintf(stderr, "APOLL in:  %d (%s), req id=%d\n",
	    audio.state, sttr[audio.state], request.id);
*/
	if (audio.state == DRAIN) {
	    audio_get_play_active(device_fd, &active);
	    if (active == 0) audio.state = IDLE;
	}

	if (audio.state == IDLE && request.id >= 0) {
	    play_setup();
	}

	if (audio.state == PLAY) play_service();

/* Post a synchronous notifier event to client "SIGPOLL", to notify
 * display code that something may have happened.
 */
	if (!event_posted) {
	    event_posted = TRUE;
	    notify_post_event(SIGPOLL, NULL, NOTIFY_SAFE);
	}

/*	fprintf(stderr, "APOLL out: %d (%s), %d %d\n",
	    audio.state, sttr[audio.state], audio.id, active);
*/
	return NOTIFY_DONE;
}

audio_set_play_translate(int fd, Audio_hdr *f_hdr, Audio_hdr *d_hdr)
{
/*
 * Set up audio file translation
 *  fd = audio device file descriptor 
 *  f_hdr = file encoding
 *  d_hdr = audio device encoding (returned)
 *  Return value:
 *  < 0: File is not compatible with audio device
 *  = 0: Audio device is configured to match file
 *  > 0: File can be translated to match device
 */
	int i;
	char str[AUDIO_MAX_ENCODE_INFO];

/* Try to set audio device to match file */

	if (fd > 0) {
	    *d_hdr = *f_hdr;
	    i = audio_set_play_config(fd, d_hdr);
	    if (i == AUDIO_SUCCESS)
	        return 0;
	    else if (i != AUDIO_ERR_NOEFFECT) {
	        printf("status %d, fd = %d\n", i, fd);
	        perror("audio_set_play_config");
	        audio_enc_to_str(f_hdr, str);
	        fprintf(stderr,"Can't convert: %s\n", str);
	        audio_enc_to_str(d_hdr, str);
	        fprintf(stderr,"           to: %s\n", str);
	        return -1;
	    }
	}

/*   Can't set device to match file -
      see if we can convert file to match device */

	return audio_setup_translate(*f_hdr, *d_hdr, 1);
}
