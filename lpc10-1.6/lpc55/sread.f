************************************************************************
*
*     NSA LPC-10 Voice Coder
*
* $Log: sread.f,v $
* Revision 1.4  1996/03/27  18:15:05  jaf
* Commented out access to ICLIP, which is just a debugging variable that
* was defined in the COMMON block CONTRL in contrl.fh.  Also commented
* out the inclusion of control.fh, which is no longer necessary.
*
* Revision 1.3  1996/03/25  20:35:29  jaf
* Added commments about which indices of array arguments are read or
* written.
*
* Rearranged local declarations to indicate which are local variables,
* constants, or function return value definitions.
*
* Revision 1.2  1996/02/12  15:17:14  jaf
* Added a few comments.
*
* Revision 1.1  1996/02/07 14:36:36  jaf
* Initial revision
*
*
************************************************************************

* 
* 'len' must be at most RECLEN=1024, otherwise these functions abort the
* program.
* 
* 
* function sread
* 
* Read in at most 'len' 16 bit audio samples from the input file
* descriptor 'fd', and convert them from 16 bit two's complement form to
* real numbers in the range -1 to +1.  The converted real samples are
* stored in the array 'buf'.  The number of such samples read is
* returned.
* 
* Input:
*  fd   - File descriptor for input file to read from.
*  len  - Maximum number of samples to read.
* Output:
*  buf  - Audio samples that were read.
*         Indices 1 through n (the function return value) written.
* Return value:
*  n    - The number of samples actually read, between 0 and len, inclusive.
* 
* 
* 
* function swrite
* 
* swrite writes out 'len' 16 bit audio samples from the array 'buf' to
* the file descriptor 'fd', converting the real values in the range -1
* to +1, to integers in the range -32768 to +32767, clipping any values
* out of range to the appropriate extreme value (the statistics counter
* iclip is incremented for every sample where this happens).  The scaled
* values are rounded/truncated in whatever way Fortran does for
* assignments of reals to integers.
* 
* Input:
*  fd   - File descriptor for input file to write to.
*  buf  - Audio samples to write.
*         Indices 1 through len read.
*  len  - Number of samples to write.
* Return value:
*  n    - The number of samples actually written.
*         If n samples are successfully written, the value returned is
*         n.  If not successful, the program is aborted.
* 
	function sread(fd, buf, len)

*	include 'contrl.fh'

*       Arguments

	integer fd, len
	real buf(len)

*       Function return value definitions

	integer sread, swrite, spd_read, spd_write

*       Parameters/constants

	integer RECLEN
	real RSCALE
	parameter (RECLEN=1024)
	parameter (RSCALE=1./32768.)

*       Local variables that need not be saved

	integer i, n
	real t, t2
	integer*2 rec(RECLEN)


	if (len .gt. RECLEN) stop 'sread: too long'
	n = spd_read(fd, rec, 2*len) / 2
	do i = 1, n
	    buf(i) = rec(i)*RSCALE
	end do
	sread = n
	return


	entry swrite(fd, buf, len)

	if (len .gt. RECLEN) stop 'swrite: too long'
	do i = 1, len
	    t = 32768.*buf(i)
	    t2 = max(-32768.,min(32767.,t))
*	    if (t .ne. t2) iclip = iclip + 1
	    rec(i) = t2
	end do
	n = spd_write(fd, rec, 2*len) / 2
	if (n .ne. len) stop 'swrite: I/O error'
	swrite = n
	return

	end
