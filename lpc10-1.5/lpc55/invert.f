*****************************************************************
*
*	INVERT Version 45G
*
* $Log: invert.f,v $
* Revision 1.3  1996/03/18  20:52:47  jaf
* Just added a few comments about which array indices of the arguments
* are used, and mentioning that this subroutine has no local state.
*
* Revision 1.2  1996/03/13  16:51:32  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Eliminated a comment from the original, describing a local array X
* that appeared nowhere in the code.
*
* Revision 1.1  1996/02/07 14:47:20  jaf
* Initial revision
*
*
*****************************************************************
*
*  Invert a covariance matrix using Choleski decomposition method.
*
* Input:
*  ORDER            - Analysis order
*  PHI(ORDER,ORDER) - Covariance matrix
*                     Indices (I,J) read, where ORDER .GE. I .GE. J .GE. 1.
*                     All other indices untouched.
*  PSI(ORDER)       - Column vector to be predicted
*                     Indices 1 through ORDER read.
* Output:
*  RC(ORDER)        - Pseudo reflection coefficients
*                     Indices 1 through ORDER written, and then possibly read.
* Internal:
*  V(ORDER,ORDER)   - Temporary matrix
*                     Same indices written as read from PHI.
*                     Many indices may be read and written again after
*                     initially being copied from PHI, but all indices
*                     are written before being read.
*
*  NOTE: Temporary matrix V is not needed and may be replaced
*    by PHI if the original PHI values do not need to be preserved.
*
	SUBROUTINE INVERT( ORDER, PHI, PSI, RC )
	INCLUDE 'config.fh'

*       Arguments

	INTEGER ORDER
	REAL PHI(ORDER,ORDER), PSI(ORDER), RC(ORDER)

*	Parameters/constants

	REAL EPS
	PARAMETER (EPS=1.0E-10)

*       Local variables that need not be saved

	INTEGER I, J, K
	REAL V(MAXORD,MAXORD), SAVE

*  Decompose PHI into V * D * V' where V is a triangular matrix whose
*   main diagonal elements are all 1, V' is the transpose of V, and
*   D is a vector.  Here D(n) is stored in location V(n,n).

	DO J = 1,ORDER
	   DO I = J,ORDER
	      V(I,J) = PHI(I,J)
	   END DO
	   DO K = 1,J-1
	      SAVE = V(J,K)*V(K,K)
	      DO I = J,ORDER
	         V(I,J) = V(I,J) - V(I,K)*SAVE
	      END DO
	   END DO

*  Compute intermediate results, which are similar to RC's

	   IF (ABS(V(J,J)) .LT. EPS) GOTO 100
	   RC(J) = PSI(J)
	   DO K = 1,J-1
	      RC(J) = RC(J) - RC(K)*V(J,K)
	   END DO
	   V(J,J) = 1./V(J,J)
	   RC(J) = RC(J)*V(J,J)
	   RC(J) = MAX(MIN(RC(J),.999),-.999)
	END DO
	RETURN

*  Zero out higher order RC's if algorithm terminated early

100	DO I = J,ORDER
	   RC(I) = 0.
	END DO

*  Back substitute for PC's (if needed)

*110	DO J = ORDER,1,-1
*	   PC(J) = RC(J)
*	   DO I = 1,J-1
*	      PC(J) = PC(J) - PC(I)*V(J,I)
*	   END DO
*	END DO

	RETURN

	END
