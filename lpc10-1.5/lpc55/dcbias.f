**********************************************************************
*
*	DCBIAS Version 50
*
* $Log: dcbias.f,v $
* Revision 1.3  1996/03/18  21:19:22  jaf
* Just added a few comments about which array indices of the arguments
* are used, and mentioning that this subroutine has no local state.
*
* Revision 1.2  1996/03/13  16:44:53  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:44:21  jaf
* Initial revision
*
*
**********************************************************************
*
* Calculate and remove DC bias from buffer.
*
* Input:
*  LEN    - Length of speech buffers
*  SPEECH - Input speech buffer
*           Indices 1 through LEN read.
* Output:
*  SIGOUT - Output speech buffer
*           Indices 1 through LEN written
*
* This subroutine has no local state.
*
	SUBROUTINE DCBIAS( LEN, SPEECH, SIGOUT )

*	Arguments

	INTEGER LEN
	REAL SPEECH(LEN), SIGOUT(LEN)

*       Local variables that need not be saved

	INTEGER I
	REAL BIAS

	BIAS = 0
	DO I = 1,LEN
	   BIAS = BIAS + SPEECH(I)
	END DO
	BIAS = BIAS/LEN
	DO I = 1,LEN
	   SIGOUT(I) = SPEECH(I) - BIAS
	END DO
	RETURN
	END
