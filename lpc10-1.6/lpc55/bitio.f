************************************************************************
*
*	BITIO Version 55
*
* $Log: bitio.f,v $
* Revision 1.3  1996/03/25  20:50:46  jaf
* Started to put comments in function and entry headers like those in
* other parts of the LPC10 coder, but gave up in the middle because it
* didn't seem worth the effort for these routines right now.
*
* Revision 1.2  1996/02/12  15:00:32  jaf
* Added a few comments, and replaced calls to ishft with calls to lshift
* or rshift, so that it would compile with f2c.
*
* Revision 1.1  1996/02/07 14:42:57  jaf
* Initial revision
*
*
************************************************************************

* function bitsrd
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

	function bitsrd(fd, ibits, n)

*       Arguments

	integer fd, n
	integer ibits(n)

*       Function return value definitions

	integer bitsrd, bitswr, gethx, puthx

*       Local variables that need not be saved

	character str*80

************************************************************************
*   Read a frame from bitstream file
************************************************************************

	bitsrd = 0
20	read(fd, 80, end=90) str
80	format(a)
	if (str(1:1).eq.'*') goto 20
	bitsrd = gethx(str, ibits, n)
90	return

************************************************************************
*   Write a frame to bitstream file
************************************************************************

	entry bitswr(fd, ibits, n)

	bitswr = puthx(str, ibits, n)
	write(fd,80) str(1:(n+3)/4)
	return

	end

************************************************************************
*   Read bits from hex digit stream
************************************************************************
*
*   Skip leading blanks, split hex digits into individual bits,
*  terminate after getting n bits or finding non-hex character.
*  Return value = number of bits in input record (which could be
*  more or less than n).

* 
* Input:
*  str   - 
* Output:
*  ibits - 
*  n     - 
* Return value:
*        - 
* 

	function gethx(str, ibits, n)

*       Arguments

	character*(*) str
	integer n, ibits(n)

*       Function return value definitions

	integer gethx, puthx

*       Parameters/constants

*       This is not a Fortran PARAMETER, but it is a character string
*       that is initialized with a DATA statement, and then never
*       modified.

	character hex*23

*       Local variables that need not be saved

	integer ib, ic, i, ii, j, k, nc

	data hex /'0123456789ABCDEFabcdef '/


	ic = 0
	do j = 1, len(str)
	    k = index(hex, str(j:j)) - 1

*       (k in 0..21) => hex digit
*       (k = 22) => space
*       (k = -1) => other

	    if (k.lt.0 .or. (k.gt.21 .and. ic.gt.0)) goto 20
	    if (k.le.21) ic = ic + 1
	end do

*       Right now we know that:
*       
*       str(1:j-ic-1) is leading white space.
*       str(j-ic:j-1) is the consecutive sequence of hex digits, if any.
*       ic is the number of hex digits, which could be 0 if there were none.
*       str(j:len(str)) is everything after any hex number found.
*       
*       nc will be the number of hex digits to process.  It should be no
*       more than the number needed to fill in the desired maximum of n
*       bits.

20	ib = 0
	j = j - ic
	nc = min((n+3)/4, ic)
	do i = 0, nc-1
	    k = index(hex, str(i+j:i+j)) - 1
	    if (k .lt. 0 .or. k.gt.21) stop 'gethx: internal error'
	    if (k .gt. 15) k = k - 6
	    do ii = 1 + max(0, 4*(nc-i)-n), 4
	        ib = ib + 1
*       
*       Sun Feb 11 12:02:51 CST 1996
*       Andy Fingerhut (jaf@arl.wustl.edu)
*       
*       The following line was originally:
*       
*	        ibits(ib) = and(ishft(k, ii-4), 1)
*       
*       It caused the following error when compiling with f2c:
*       
*       Error on line 70: Declaration error for ishft: attempt to use
*       untyped function
*       
*       The value of ishft(a,b) is the integer a shifted left by b bits,
*       if b >=0, or the integer a shifted right by (-b) bits, if b < 0.
*       
*       The variable ii is always in the range 1 to 4, so ii-4 is always
*       <= 0.  Given the f2c intrinsic function rshift(a,b), ishft(k,
*       ii-4) is equivalent to rshift(k, 4-ii).
*       
*       See the definition of variable 'intrtab' of file intr.c in the
*       f2c distribution for a list of all intrinsic functions
*       recognized by f2c.
* 
	        ibits(ib) = and(rshift(k, 4-ii), 1)
	    end do
	end do

90	gethx = ib
	if (ic .gt. nc) gethx = 4*ic
	return

************************************************************************
*   Write bits to hex digit stream
************************************************************************

	entry puthx(str, ibits, n)

	ib = 0
	str = ' '
	nc = (n+3) / 4
	do ic = 1, min(len(str), nc)
	    k = 0
	    do j = 1, min(n-4*(nc-ic), 4)
	        ib = ib + 1
*       
*       The line below used to be:
*       
*	        k = or(ishft(k,1), and(ibits(ib),1))
*       
*       Replacing the call to ishft(k,1), which returns the result of k
*       shifted left by 1 bit position, with the f2c intrinsic
*       lshift(k,1).
*       
	        k = or(lshift(k,1), and(ibits(ib),1))
	    end do
	    str(ic:ic) = hex(k+1:k+1)
	end do

	puthx = ib
	return
	end
