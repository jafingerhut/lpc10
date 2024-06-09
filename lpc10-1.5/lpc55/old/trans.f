**********************************************************************
*
*	TRANS Version 54
*
* $Log: trans.f,v $
* Revision 1.2  1996/03/21  21:37:51  jaf
* Cleaned up local variable definitions a bit.
*
* Revision 1.1  1996/02/07 14:50:02  jaf
* Initial revision
*
*
**********************************************************************
*
*   Handle Quantization and Input/Output of LPC parameters
*
* Input/Output:
*  VOICE - Half frame voicing decisions
*  PITCH - Pitch index
*  RMS   - Energy
*  RC    - Reflection coefficients
*  EOF   - End of file flag
*

	subroutine trans(voice, pitch, rms, rc, eof)
	include 'config.fh'
	include 'contrl.fh'

*       Arguments

	integer voice(2), pitch
	real rms, rc(order)
	logical eof

*       Function return value definitions

	integer bitsrd, bitswr, spd_read, spd_write

*       Parameters/constants

	integer NPB
	parameter (NPB = MAXORD+4)

*       Local variables that need not be saved

	real pbuf(NPB)
	integer i, ipitv, irms, irc(MAXORD), ibits(MAXNB)

*  Read unquantized parameters from file,
*     or use parameters analyzed from input speech

	eof = .false.
	if (fsi.ge.0 .or. fpi.ge.0) then
	   if (fpi .ge. 0) then
	      if(pbin .eq. 0) then
	         read(fpi, *, end=900) rms, voice, pitch, (rc(i),i=1,order)
	      else
	         i = spd_read(fpi, pbuf, 4*NPB)
	         if (i .ne. 4*NPB) goto 900
	         rms = pbuf(1)
	         voice(1) = pbuf(2)
	         voice(2) = pbuf(3)
	         pitch = pbuf(4)
	         do i = 1, order
	            rc(i) = pbuf(4+i)
	         end do
	         write(pbin,rec=1) nframe
	      end if
	   end if

*     Quantize to 2400 bps, or pass them unquantized

	   if (quant .eq. 2400) then
	      call encode(voice, pitch, rms, rc, ipitv, irms, irc)
	      call chanwr(order, ipitv, irms, irc, ibits)

	   else if (fsi .ge. 0) then
	      call pitdec(pitch, i)
	      pitch = i
	   end if
	end if

*  Decode parameters from bitstream

	if (quant .eq. 2400) then
	   if (fbi .ge. 0) then
	      i = bitsrd(fbi, ibits, nbits)
	      if (i .ne. nbits) then
	         if (i .gt. 0) write(fmsg,*)
     1              'ERROR: trans: expected', nbits, ' bits, got', i
	         goto 900
	      end if
	   end if
	   if (fbo .ge. 0) i = bitswr(fbo, ibits, nbits)
	   call chanrd(order, ipitv, irms, irc, ibits)
	   call decode(ipitv, irms, irc, voice, pitch, rms, rc)
	end if

*  Write (optionally quantized) floating point parameters to file

	if (fpo .ge. 0) then
	   if (pbin .eq. 0) then
	      write(fpo, 1000) rms, voice, pitch, (rc(i), i=1,order)
	   else
	      pbuf(1) = rms
	      pbuf(2) = voice(1)
	      pbuf(3) = voice(2)
	      pbuf(4) = pitch
	      do i = 1, order
	         pbuf(4+i) = rc(i)
	      end do
	      i = spd_write(fpo, pbuf, 4*NPB)
	   end if
	end if
	return

900	eof = .true.
	return

1000	format(1x, f8.2, i3, i2, i4, 10f8.4)
	end
