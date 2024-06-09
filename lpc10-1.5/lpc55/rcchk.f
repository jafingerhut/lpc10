**********************************************************************
*
*	RCCHK Version 45G
*
* $Log: rcchk.f,v $
* Revision 1.4  1996/03/27  18:13:47  jaf
* Commented out a call to subroutine ERROR.
*
* Revision 1.3  1996/03/18  15:48:53  jaf
* Just added a few comments about which array indices of the arguments
* are used, and mentioning that this subroutine has no local state.
*
* Revision 1.2  1996/03/13  16:55:22  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:49:08  jaf
* Initial revision
*
*
**********************************************************************
*
*  Check RC's, repeat previous frame's RC's if unstable
*
* Input:
*  ORDER - Number of RC's
*  RC1F  - Previous frame's RC's
*          Indices 1 through ORDER may be read.
* Input/Output:
*  RC2F  - Present frame's RC's
*          Indices 1 through ORDER may be read, and written.
*
* This subroutine has no local state.
*
	SUBROUTINE RCCHK( ORDER, RC1F, RC2F )

*       Arguments

	INTEGER ORDER
	REAL RC1F(ORDER), RC2F(ORDER)

*       Local variables that need not be saved

	INTEGER I

	DO I = 1,ORDER
	   IF(ABS(RC2F(I)).GT..99) GOTO 10
	END DO
	RETURN

*       Note: In version embedded in other software, all calls to ERROR
*       should probably be removed.

10	CONTINUE

*       
*       This call to ERROR is only needed for debugging purposes.
*       
*       CALL ERROR('RCCHK',2,I)

	DO I = 1,ORDER
	   RC2F(I) = RC1F(I)
	END DO
	RETURN
	END
