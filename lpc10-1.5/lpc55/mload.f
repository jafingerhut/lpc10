******************************************************************
*
*	MLOAD Version 48
*
* $Log: mload.f,v $
* Revision 1.5  1996/03/27  23:59:51  jaf
* Added some more accurate comments about which indices of the argument
* array SPEECH are read.  I thought that this might be the cause of a
* problem I've been having, but it isn't.
*
* Revision 1.4  1996/03/26  19:16:53  jaf
* Commented out the code at the end that copied the lower triangular
* half of PHI into the upper triangular half (making the resulting
* matrix symmetric).  The upper triangular half was never used by later
* code in subroutine ANALYS.
*
* Revision 1.3  1996/03/18  21:16:00  jaf
* Just added a few comments about which array indices of the arguments
* are used, and mentioning that this subroutine has no local state.
*
* Revision 1.2  1996/03/13  16:47:41  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:48:01  jaf
* Initial revision
*
*
******************************************************************
*
* Load a covariance matrix.
*
* Input:
*  ORDER            - Analysis order
*  AWINS            - Analysis window start
*  AWINF            - Analysis window finish
*  SPEECH(AWINF)    - Speech buffer
*                     Indices MIN(AWINS, AWINF-(ORDER-1)) through
*                             MAX(AWINF, AWINS+(ORDER-1)) read.
*                     As long as (AWINF-AWINS) .GE. (ORDER-1),
*                     this is just indices AWINS through AWINF.
* Output:
*  PHI(ORDER,ORDER) - Covariance matrix
*                     Lower triangular half and diagonal written, and read.
*                     Upper triangular half untouched.
*  PSI(ORDER)       - Prediction vector
*                     Indices 1 through ORDER written,
*                     and most are read after that.
*
* This subroutine has no local state.
*

	SUBROUTINE MLOAD( ORDER, AWINS, AWINF, SPEECH, PHI, PSI )

*       Arguments

	INTEGER ORDER, AWINS, AWINF
	REAL SPEECH(AWINF)
	REAL PHI(ORDER,ORDER), PSI(ORDER)

*       Local variables that need not be saved

	INTEGER R, C, I, START

*   Load first column of triangular covariance matrix PHI

	START = AWINS + ORDER
	DO R = 1,ORDER
	   PHI(R,1) = 0.
	   DO I = START,AWINF
	      PHI(R,1) = PHI(R,1) + SPEECH(I-1)*SPEECH(I-R)
	   END DO
	END DO

*   Load last element of vector PSI

	PSI(ORDER) = 0.
	DO I = START,AWINF
	   PSI(ORDER) = PSI(ORDER) + SPEECH(I)*SPEECH(I-ORDER)
	END DO

*   End correct to get additional columns of PHI

	DO R = 2,ORDER
	   DO C = 2,R
	      PHI(R,C) = PHI(R-1,C-1)
     1                  - SPEECH(AWINF+1-R)*SPEECH(AWINF+1-C)
     1                    + SPEECH(START-R)*SPEECH(START-C)
	   END DO
	END DO

*   End correct to get additional elements of PSI

	DO C = 1,ORDER-1
	   PSI(C) = PHI(C+1,1) - SPEECH(START-1)*SPEECH(START-1-C)
     1                          + SPEECH(AWINF)*SPEECH(AWINF-C)
	END DO

*   Copy lower triangular section into upper (why bother?)

*       I'm commenting this out, since the upper triangular half of PHI
*       is never used by later code, unless a sufficiently high level of
*       tracing is turned on.

*	DO R = 1,ORDER
*	   DO C = 1,R-1
*	      PHI(C,R) = PHI(R,C)
*	   END DO
*	END DO

	RETURN
	END
