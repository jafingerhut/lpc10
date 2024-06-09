***********************************************************************
*
*	DIFMAG Version 49
*
* $Log: difmag.f,v $
* Revision 1.3  1996/03/15  23:09:39  jaf
* Just added a few comments about which array indices of the arguments
* are used, and mentioning that this subroutine has no local state.
*
* Revision 1.2  1996/03/13  14:41:31  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:45:04  jaf
* Initial revision
*
*
**********************************************************************
*
*  Compute Average Magnitude Difference Function
*
* Inputs:
*  SPEECH - Low pass filtered speech
*           Indices MIN_N1 through MAX_N1+LPITA-1 are read, where
*       MIN_N1 = (MAXLAG - MAX_TAU)/2+1  MAX_TAU = max of TAU(I) for I=1,LTAU
*       MAX_N1 = (MAXLAG - MIN_TAU)/2+1  MIN_TAU = min of TAU(I) for I=1,LTAU
*  LPITA  - Length of speech buffer
*  TAU    - Table of lags
*           Indices 1 through LTAU read.
*  LTAU   - Number of lag values to compute
*  MAXLAG - Maximum possible lag value
* Outputs:
*  (All of these outputs are also read, but only after being written.)
*  AMDF   - Average Magnitude Difference for each lag in TAU
*           Indices 1 through LTAU written
*  MINPTR - Index of minimum AMDF value
*  MAXPTR - Index of maximum AMDF value
*
* This subroutine has no local state.
*

	SUBROUTINE DIFMAG( SPEECH, LPITA, TAU, LTAU, MAXLAG,
     1                    AMDF, MINPTR, MAXPTR )

*       Arguments

	INTEGER LPITA, LTAU, MAXLAG, MINPTR, MAXPTR
	INTEGER TAU(LTAU)
	REAL SPEECH(LPITA+MAXLAG), AMDF(LTAU)

*       Local variables that need not be saved

	INTEGER I, J, N1, N2
	REAL SUM

*       Local state

*       None

	MINPTR = 1
	MAXPTR = 1
	DO I = 1,LTAU
	   N1 = (MAXLAG-TAU(I))/2 + 1
	   N2 = N1 + LPITA - 1
	   SUM = 0.
	   DO J = N1,N2,4
	      SUM = SUM + ABS( SPEECH(J) - SPEECH(J+TAU(I)) )
	   END DO
	   AMDF(I) = SUM
	   IF( AMDF(I).LT.AMDF(MINPTR) ) MINPTR = I
	   IF( AMDF(I).GT.AMDF(MAXPTR) ) MAXPTR = I
	END DO
	RETURN
	END
