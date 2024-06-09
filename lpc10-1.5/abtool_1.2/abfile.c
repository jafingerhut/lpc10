#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <math.h>
#include <multimedia/libaudio.h>
#include "abplay.h"

#define	MAX(a, b)	((a) < (b) ? (b) : (a))
#define	MIN(a, b)	((a) < (b) ? (a) : (b))
#define INFO_SIZE	80	/* Max length of file description string */
#define NSMAX		1000	/* Maximum number of segments */
#define STEPMAX 	2400	/* Max samples/energy point = 50 ms.*48 KHz */
#define SIG_SIZE 	4096	/* Audio output buffer size (>= STEPMAX!) */

static struct abfile abf[MAXFILES]; /* One of these for each file */
static struct segstate sg;	/* Energy/segmentation state */
static struct seg seg[NSMAX];	/* start, end (secs) of each segment */
static int nfiles = 0;		/* Number of currently open files */

/*
 * Open a signal file and initialize its abfile header.
 */
abp_open_file(char *file)
{
	int fd, nsamp, nstep, hlen, i, j, n, trans;
	caddr_t base;
	struct stat st;
	struct abfile *f;
	char info[INFO_SIZE+1];
	float win[STEPMAX];
	float erms1, erms2, epeak, *w1, *w2, *rb, *pb, t;
	char *ip;
	short *bp;
	char etbuf[SIG_SIZE];
	Audio_hdr default_hdr;	/* Defaults for headerless (spd) files */

   /* Open file, get its size, and mmap it */

	fd = open(file, O_RDONLY);
	if (fd < 0 || fstat(fd, &st) < 0) return Perr(fd, "open", file);
	if (!S_ISREG(st.st_mode))
	    return Pmsg(fd, "open: not a regular file", file);
	base = mmap(0, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
	if (base < (caddr_t)0) return Perr(fd, "mmap", file);

   /* Find first empty file slot */

	if (nfiles >= MAXFILES) return Pmsg(fd, "open: too many files", file);
	abf[nfiles].id = -1;
	for (j=0; j<=nfiles; j++) if (abf[j].id < 0) break;
	if (j == nfiles) nfiles += 1;
	f = &abf[j];

   /* Fill in the misc details */

	f->id = j;
	f->fd = fd;
	f->data = base;
	f->dsize = st.st_size;
	f->p.scale = 1.0;

   /* Get the audio header */

  /* Set defaults for files without audio headers - spd files */

	default_hdr.sample_rate = 8000;		/* 8 KHz */
	default_hdr.samples_per_unit = 1;	/* no blocking */
	default_hdr.bytes_per_unit = 2;		/* 16-bit samples */
	default_hdr.channels = 1;		/* monophonic */
	default_hdr.encoding = AUDIO_ENCODING_LINEAR;	/* linear */
	default_hdr.data_size = AUDIO_UNKNOWN_SIZE;	/* fill in later */

	if (audio_read_filehdr(fd, &f->h, info, INFO_SIZE) != AUDIO_SUCCESS) {
	    lseek(fd, 0L, SEEK_SET);	/* rewind file */
	    f->h = default_hdr;		/* not a Sun audio file - fake it */
	    info[0] = 0;
	}
	if (f->h.bytes_per_unit == 0) {
	    printf("bogus header - using default 16 bit linear encoding\n");
	    f->h = default_hdr;
	}
	f->hsize = lseek(fd, 0L, SEEK_CUR);
	if (f->h.data_size == AUDIO_UNKNOWN_SIZE)
	    f->h.data_size = f->dsize - f->hsize;

   /* Allocate energy buffers, set up translation to 16 bit linear */

	sg.step = .020;				/* Energy step size (20 ms.) */
	nsamp = f->h.samples_per_unit * (f->h.data_size/f->h.bytes_per_unit);
	nstep = nint(f->h.sample_rate * sg.step);	/* samples per step */
	f->esize = (nsamp-1) / nstep + 1;	/* # of energy points */
	f->rbuf = (float *)calloc(f->esize, sizeof(*f->rbuf));
	f->pbuf = (float *)calloc(f->esize, sizeof(*f->pbuf));
	if (f->rbuf==0 || f->pbuf==0) Perr(0, "abtool", "buffer alloc failed");
	trans = audio_setup_translate(f->h, default_hdr, 1);
	if (trans < 0) return -1;

/*	printf("hsize = %d, s/u = %d, b/u = %d, srate = %d\n", f->hsize,
	    f->h.samples_per_unit, f->h.bytes_per_unit, f->h.sample_rate);
	printf("nsamp = %d, nstep = %d, esize = %d\n", nsamp, nstep, f->esize);
*/

   /* Calculate the energy tracks */

	for (j=0, w2=win; j <= nstep; j++) *w2++ = 1.0 / nstep;
	ip = f->data + f->hsize;
	n = nstep * f->h.bytes_per_unit;
	rb = f->rbuf;
	pb = f->pbuf;
	erms1 = 0.0;
	for (i = 0; i < f->esize-1; i++) {
	    erms2 = erms1;
	    erms1 = epeak = 0.0;
	    w1 = win + nstep;
	    w2 = win;
	    if (trans == 0)
	        bp = (short *)ip;
	    else {
	        bp = (short *)etbuf;
	        j = audio_translate(trans, ip, etbuf, n);
	    }
	    ip += n;
	    for (j = 0; j < nstep; j++) {
	        t = *bp++;
	        epeak = MAX(epeak, abs(t));
	        t = t*t;
	        erms1 += t**w1--;
	        erms2 += t**w2++;
	    }
	    *rb++ = 10.*log10((double)MAX(erms2, 1.0));
	    *pb++ = 20.*log10((double)MAX(epeak, 1.0));
	}
	*rb++ = 10.*log10((double)MAX(erms1, 1.0));
	*pb++ = 0.0;

/*	printf("'%s' opened (%d,%d), len = %d, elen = %d\n",
	    file, f->id, nfiles, nsamp, f->esize);
	if (info[0] != 0) printf("'%s'\n", info);
*/
	abp_align(f->id, 0.0, sg.p.taumax);
	return f->id;
}

abp_close_file(int id)
{
	struct abfile *f;
	struct audio_status status;

	if (id<0 || id>=nfiles || id!=abf[id].id) {
	    fprintf(stderr, "close: invalid file (%d)\n", id);
	    return -1;
	}
	abp_get_audio_status(&status);
	if (id == status.id && status.state != IDLE) abp_abort_play();
	if (id == sg.id) sg.id = -1;
	f = &abf[id];
	f->id = -1;
	munmap(f->data, f->dsize);
	free(f->rbuf);
	free(f->pbuf);
	close(f->fd);
	return 0;
}

struct abfile *
abp_get_abfile(int id)
{
	if (id<0 || id>=nfiles || id!=abf[id].id) return (struct abfile *)0;
	return &abf[id];
}

struct segstate
abp_get_segstate()
{
	return sg;
}

abp_segment(int id, struct segparms parm)
{
	int i, nstart, nend, newseg, npad, ngap;
	int nsmax = NSMAX;

	sg.id = -1;
	sg.nsegs = 0;
	if (id<0 || id>=nfiles || id!=abf[id].id)
	    return sg.nsegs;

	sg.id = id;
	sg.p = parm;
	sg.elength = abf[id].esize;
	sg.segs = seg;
	sg.energy = abf[id].rbuf;

	nstart = sg.elength;
	nend = 0;
	newseg = 0;
	ngap = nint(.001*sg.p.gap / sg.step);
	npad = nint(.001*sg.p.pad / sg.step);

	for (i = 0; i < sg.elength; i++) {
	    if (sg.energy[i] > (float)sg.p.thresh && i < sg.elength-1) {
	        nstart = MIN(nstart, i);
	        nend = MAX(nend, i);
	        newseg = 1;
	    } else if (newseg > 0) {
	        if (i >= sg.elength-1 || i > nend+ngap) {
	            seg[sg.nsegs].start = sg.step * MAX(nstart-npad, 0);
	            seg[sg.nsegs].end = sg.step * MIN(nend+npad, sg.elength);
	            sg.nsegs += 1;
	            newseg = 0;
	            if (sg.nsegs >= nsmax) break;
	            nstart = sg.elength;
	            nend = 0;
	        }
	    }
	}
/*	fprintf(stderr, "segment id=%d, thr=%d, gap=%d, pad=%d, nsegs=%d\n",
	    id, sg.p.thresh, ngap, npad, sg.nsegs); */

	for (i = 0; i < nfiles; i++)
	    abp_align(i, 0.0, sg.p.taumax);

	return sg.nsegs;
}

abp_align(int id2, double tau, double taumax)
{
	int id1, n1, n2, i, m, maxm;
	float t, c, *e1, *e2;
	double corr();

	if (id2<0 || id2>=nfiles || abf[id2].id != id2) return -1;
	abf[id2].p.corr = abf[id2].p.delay = 0.0;
	id1 = sg.id;
	if (id1<0 || id1>=nfiles || abf[id1].id != id1) return -1;

	n1 = abf[id1].esize;
	n2 = abf[id2].esize;
	e1 = abf[id1].rbuf;
	e2 = abf[id2].rbuf;

	m = nint(tau / sg.step);
	if (m != 0) {
	    c = corr(n1, n2-m, e1, e2+m);
	} else {
	    c = corr(n1, n2, e1, e2);
	    maxm = nint(taumax / sg.step);
	    for (i = 1; i < maxm; i++) {
	        if ((t = corr(n1, n2-i, e1, e2+i)) > c) {
	            c = t;
	            m = i;
	        }
	        if ((t = corr(n1-i, n2, e1+i, e2)) > c) {
	            c = t;
	            m = -i;
	        }
	    }
	}
	abf[id2].p.delay = m * sg.step;
	abf[id2].p.corr = c / sqrt(corr(n1,n1,e1,e1) * corr(n2,n2,e2,e2));

/*	fprintf(stderr, "corr(%d, %d) = %6.3f at %6.3f sec\n",
	    id1, id2, abf[id2].p.corr, abf[id2].p.delay);   */

	return 1;
}

double
corr(int n1, int n2, float *e1, float *e2)
{
	int i, n;
	double t;

	n = MIN(n1, n2);
	t = 0.0;
	for (i = 0; i < n; i++) t += (*e1++) * (*e2++);
	return t;
}

Perr(int fd, char *s1, char *s2)
{
	if (fd > 0) close(fd);
	fprintf(stderr, "%s: ", s1);
	perror(s2);
	return -1;
}

Pmsg(int fd, char *s1, char *s2)
{
	if (fd > 0) close(fd);
	fprintf(stderr, "%s: %s\n", s1, s2);
	return(-1);
}
