**********************************************************************
*
*	ENERGY Version 50
*
* $Log: energy.f,v $
* Revision 1.3  1996/03/18  21:17:41  jaf
* Just added a few comments about which array indices of the arguments
* are used, and mentioning that this subroutine has no local state.
*
* Revision 1.2  1996/03/13  16:46:02  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:45:40  jaf
* Initial revision
*
*
**********************************************************************
*
* Compute RMS energy.
*
* Input:
*  LEN    - Length of speech buffer
*  SPEECH - Speech buffer
*           Indices 1 through LEN read.
* Output:
*  RMS    - Root Mean Square energy
*
* This subroutine has no local state.
*
	SUBROUTINE ENERGY( LEN, SPEECH, RMS )

*       Arguments

	INTEGER LEN
	REAL SPEECH(LEN), RMS

*       Local variables that need not be saved

	INTEGER I

	RMS = 0
	DO I = 1,LEN
	   RMS = RMS + SPEECH(I)*SPEECH(I)
	END DO
	RMS = SQRT( RMS / LEN )
	RETURN
	END
