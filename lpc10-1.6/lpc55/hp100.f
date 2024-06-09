**********************************************************************
*
*      HP100 Version 55
*
* $Log: hp100.f,v $
* Revision 1.6  1996/03/15  16:45:25  jaf
* Rearranged a few comments.
*
* Revision 1.5  1996/03/14  23:20:54  jaf
* Added comments about when INITHP100 should be used.
*
* Revision 1.4  1996/03/14  23:08:08  jaf
* Added an entry named INITHP100 that initializes the local state of
* subroutine HP100.
*
* Revision 1.3  1996/03/14  22:09:20  jaf
* Comments added explaining which of the local variables of this
* subroutine need to be saved from one invocation to the next, and which
* do not.
*
* Revision 1.2  1996/02/12  15:05:54  jaf
* Added lots of comments explaining why I changed one line, which was a
* declaration with initializations.
*
* Revision 1.1  1996/02/07 14:47:12  jaf
* Initial revision
*
*
**********************************************************************
*
*    100 Hz High Pass Filter
*
* Jan 92 - corrected typo (1.937148 to 1.935715),
*          rounded coefficients to 7 places,
*          corrected and merged gain (.97466**4),
*          merged numerator into first two sections.
*
* Input:
*  start, end - Range of samples to filter
* Input/Output:
*  speech(end) - Speech data.
*                Indices start through end are read and modified.
* 
* This subroutine maintains local state from one call to the next.  If
* you want to switch to using a new audio stream for this filter, or
* reinitialize its state for any other reason, call the ENTRY
* INITHP100.

	subroutine hp100(speech, start, end)

*       Arguments

	integer start, end
	real speech(end)

*       Local variables that need not be saved

	integer i
	real si, err

*       Local state

	real z11, z21, z12, z22
	data z11/0./, z21/0./, z12/0./, z22/0./
	save z11, z21, z12, z22

	do i = start,end
	    si = speech(i)

	    err = si + 1.859076*z11 - .8648249*z21
	    si = err - 2.00*z11 + z21
	    z21 = z11
	    z11 = err

	    err = si + 1.935715*z12 - .9417004*z22
	    si = err - 2.00*z12 + z22
	    z22 = z12
	    z12 = err

	    speech(i) = .902428*si
	end do

	return


	entry inithp100 ()

	z11 = 0.
	z21 = 0.
	z12 = 0.
	z22 = 0.

	return
	end


*       I believe that the desired result of the original declaration of
*       z11, z21, z12, and z22, shown here:
*       
*	real z11/0/, z21/0/, z12/0/, z22/0/
*       
*       was that these values would be initialized to 0 at the beginning
*       of the execution of the program, _and_ that whatever values they
*       had when this subroutine returns would be preserved when the
*       subroutine is called the next time.
*       
*       From my cursory reading of the Fortran 77 statement, the value
*       of these local variables should be undefined on all but the
*       first call, when they are known to be 0 because of the
*       initialization.  That is, the line above could be replaced with
*       the following more explicit lines:
*       
*	real z11/0/, z21/0/, z12/0/, z22/0/
*       save z11, z21, z12, z22
*       
*       Furthermore, the free Fortran to C translator f2c gives an error
*       message for declarations of variables with initializations, so
*       I'm going to replace the two lines above with the following:
*       
*	real z11, z21, z12, z22
*	data z11/0/, z21/0/, z12/0/, z22/0/
*       save z11, z21, z12, z22
*       
*       Verbose, I know, but very explicit!  I don't worry too much
*       about verbosity, as you can tell from these comments :-)
