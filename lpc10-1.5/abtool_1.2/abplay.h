#include <multimedia/audio_hdr.h>

/* Audio state definitions */
#define IDLE	0	/* Nothing happenin' */
#define DRAIN	1	/* No new input, but device still playing */
#define PLAY	2	/* Active playing */

#define MAXFILES 26	/* Max number of open speech files */

/* Per-file variables */

struct playparms {
	float delay;	/* Time delay (sec) added to segments for this file */
	float corr;	/* Correlation between segment file and this file */
	float scale;	/* Scale factor for normalizing play level */
};

struct abfile {
	int id;		/* file index (A=0, B=1, etc.) */
	int fd;		/* file descriptor (returned by open(2)) */
	Audio_hdr h;	/* Audio header, default or from file header */
	caddr_t data;	/* Base address of mmap'ed file */
	int dsize;	/* Total number of bytes in file */
	int hsize;	/* Audio header length */
	int esize;	/* Number of energy points (sample_count/step_size) */
	float *rbuf;	/* RMS energy contour */
	float *pbuf;	/* Peak signal level contour */
	struct playparms p;
};

/* Segement definitions */
struct seg {
	float start;	/* Segment beginning (ms.) */
	float end;	/* Segment end (ms.) */
};

struct segparms {
	int thresh;	/* Energy threshold (dB) above which is speech */
	int gap;	/* Minimum gap between segments (ms.) */
	int pad;	/* Amount of silence included with segment (ms.) */
	float taumax;	/* Maximum delay (sec) to search for energy match */
};

struct segstate {
	int nsegs;		/* Number of currently defined segments */
	struct seg *segs;	/* Segment array */
	int id;			/* File index for which segs were calculated */
	int elength;		/* Number of points in energy array */
	float *energy;		/* Energy array for file 'id' */
	float step;		/* Energy step size (seconds per point) */
	struct segparms p;	/* Parameters used for segmentation */
};

/* Audio info for updating display */
struct audio_status {
	int state;	/* IDLE, PLAY, or DRAIN */
	int id;		/* file id currently playing */
};

struct abfile	*abp_get_abfile();	/* Return structure for file id */
struct segstate	abp_get_segstate();	/* Return global parameters */
