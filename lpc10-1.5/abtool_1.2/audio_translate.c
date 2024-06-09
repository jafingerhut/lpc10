#include <stdio.h>
#include <multimedia/libaudio.h>

#define X2C 0x10
#define X2S 0x20
#define X2L 0x30
#define X2F 0x40
#define X2D 0x50
#define X2U 0x60
#define C2X 0x100
#define S2X 0x200
#define L2X 0x300
#define F2X 0x400
#define D2X 0x500
#define U2X 0x600

/*
 * Set up audio file translation
 *   If verbose > 0, print diagnostics on stderr if translation fails
 *   return:
 *       >0 - magic cookie to be passed to audio_translate
 *        0 - output = input encoding, no translation required
 *       -1 - translation not available
 */

audio_setup_translate(in_hdr, out_hdr, verbose)
Audio_hdr	in_hdr, out_hdr;	/* Input and output encoding formats */
int		verbose;
{
	int trans = -1;
	char msg[AUDIO_MAX_ENCODE_INFO];

/* See if headers are identical */

	if (in_hdr.encoding == out_hdr.encoding &&
	    in_hdr.channels == out_hdr.channels &&
	    in_hdr.sample_rate == out_hdr.sample_rate &&
	    in_hdr.bytes_per_unit == out_hdr.bytes_per_unit &&
	    in_hdr.samples_per_unit == out_hdr.samples_per_unit) return 0;

/* Check for valid samples_per_unit and channels */

	if ((in_hdr.samples_per_unit != 1) || (out_hdr.samples_per_unit != 1))
	    return(-1);
	if (in_hdr.channels != out_hdr.channels)
	    return(-1);

/* Determine input encoding format */

	switch (in_hdr.encoding) {
	    case AUDIO_ENCODING_ULAW:
		switch (in_hdr.bytes_per_unit) {
		    case sizeof(char): trans = U2X; break;
		}
		break;
	    case AUDIO_ENCODING_LINEAR:
		switch (in_hdr.bytes_per_unit) {
		    case sizeof(char):   trans = C2X; break;
		    case sizeof(short):  trans = S2X; break;
		    case sizeof(long):   trans = L2X; break;
		}
		break;
	    case AUDIO_ENCODING_FLOAT:
		switch (in_hdr.bytes_per_unit) {
		    case sizeof(float):  trans = F2X; break;
		    case sizeof(double): trans = D2X; break;
		}
		break;
	}

/* Punt if input encoding not recognized */

	if (trans > 0) {

/* Determine output encoding format */

	    switch (out_hdr.encoding) {
	    case AUDIO_ENCODING_ULAW:
		switch (out_hdr.bytes_per_unit) {
		    case sizeof(char): trans |= X2U; break;
		}
		break;
	    case AUDIO_ENCODING_LINEAR:
		switch (out_hdr.bytes_per_unit) {
		    case sizeof(char):   trans |= X2C; break;
		    case sizeof(short):  trans |= X2S; break;
		    case sizeof(long):   trans |= X2L; break;
		}
		break;
	    case AUDIO_ENCODING_FLOAT:
		switch (out_hdr.bytes_per_unit) {
		    case sizeof(float):  trans |= X2F; break;
		    case sizeof(double): trans |= X2D; break;
		}
		break;
	    }
	}

/* Return complete format translation cookie */

	if (trans < 0 && verbose > 0) {
	    audio_enc_to_str(&in_hdr, msg);
	    fprintf(stderr, "can't convert from: %s\n", msg);
	    audio_enc_to_str(&out_hdr, msg);
	    fprintf(stderr, "                to: %s\n", msg);
	}
	return(trans);
}

/*
 *  Translate cnt bytes from ibuf to obuf, return output byte count
 */

audio_translate(trans, ibuf, obuf, cnt)	/* Return value = output byte count */
    int	trans;		/* Magic cookie from 'audio_setup_translate' */
    int	cnt;		/* Input byte count */
    void *ibuf, *obuf;	/* Input and output buffers of indeterminate type */
{
   /* Initialize buffer pointers of various types */

	unsigned char *i_u = (unsigned char *)ibuf;
	unsigned char *o_u = (unsigned char *)obuf;
	char   *i_c =   (char *)ibuf, *o_c =   (char *)obuf;
	short  *i_s =  (short *)ibuf, *o_s =  (short *)obuf;
	long   *i_l =   (long *)ibuf, *o_l =   (long *)obuf;
	float  *i_f =  (float *)ibuf, *o_f =  (float *)obuf;
	double *i_d = (double *)ibuf, *o_d = (double *)obuf;

	int i, n;

	switch (trans) {
	    case L2X|X2U: { n = cnt/sizeof(long);
		for(i=0; i<n; i++) *o_u++ = audio_l2u(*i_l++);
		n = n*sizeof(char); break; }
	    case S2X|X2U: { n = cnt/sizeof(short);
		for(i=0; i<n; i++) *o_u++ = audio_s2u(*i_s++);
		n = n*sizeof(char); break; }
	    case C2X|X2U: { n = cnt/sizeof(char);
		for(i=0; i<n; i++) *o_u++ = audio_l2u(*i_c++);
		n = n*sizeof(char); break; }
	    case U2X|X2L: { n = cnt/sizeof(char);
		for(i=0; i<n; i++) *o_l++ = audio_u2l(*i_u++);
		n = n*sizeof(long); break; }
	    case U2X|X2S: { n = cnt/sizeof(char);
		for(i=0; i<n; i++) *o_s++ = audio_u2s(*i_u++);
		n = n*sizeof(short); break; }
	    case U2X|X2C: { n = cnt/sizeof(char);
		for(i=0; i<n; i++) *o_c++ = audio_u2c(*i_u++);
		n = n*sizeof(char); break; }
	    default:
		return(-1);
	}
	return(n);
}
