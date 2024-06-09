**********************************************************************
*
*	IVFILT Version 48
*
* $Log: ivfilt.f,v $
* Revision 1.3  1996/03/15  21:36:29  jaf
* Just added a few comments about which array indices of the arguments
* are used, and mentioning that this subroutine has no local state.
*
* Revision 1.2  1996/03/13  00:01:00  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:47:34  jaf
* Initial revision
*
*
**********************************************************************
*
*   2nd order inverse filter, speech is decimated 4:1
*
* Input:
*  LEN    - Length of speech buffers
*  NSAMP  - Number of samples to filter
*  LPBUF  - Low pass filtered speech buffer
*           Indices LEN-NSAMP-7 through LEN read.
* Output:
*  IVBUF  - Inverse filtered speech buffer
*           Indices LEN-NSAMP+1 through LEN written.
*  IVRC   - Inverse filter reflection coefficients (for voicing)
*           Indices 1 and 2 both written (also read, but only after writing).
*
* This subroutine has no local state.
*
	SUBROUTINE IVFILT( LPBUF, IVBUF, LEN, NSAMP, IVRC )

*	Arguments

	INTEGER LEN, NSAMP
	REAL LPBUF(LEN), IVBUF(LEN)
	REAL IVRC(2)

*       Local variables that need not be saved

	INTEGER I, J, K
	REAL R(3), PC1, PC2

*       Local state

*       None

*  Calculate Autocorrelations

	DO I = 1,3
	   R(I) = 0.
	   K = 4*(I-1)
	   DO J = I*4+LEN-NSAMP,LEN,2
	      R(I) = R(I) + LPBUF(J)*LPBUF(J-K)
	   END DO
	END DO

*  Calculate predictor coefficients

	PC1 = 0.
	PC2 = 0.
	IVRC(1) = 0.
	IVRC(2) = 0.
	IF (R(1) .GT. 1.0E-10) THEN
	   IVRC(1) = R(2)/R(1)
	   IVRC(2) = (R(3)-IVRC(1)*R(2)) / (R(1)-IVRC(1)*R(2))
	   PC1 = IVRC(1) - IVRC(1)*IVRC(2)
	   PC2 = IVRC(2)
	END IF

*  Inverse filter LPBUF into IVBUF

	DO I = LEN+1-NSAMP,LEN
	   IVBUF(I) = LPBUF(I) - PC1*LPBUF(I-4) - PC2*LPBUF(I-8)
	END DO

	RETURN
	END
