******************************************************************
*
*	IRC2PC Version 48
*
* $Log: irc2pc.f,v $
* Revision 1.3  1996/03/20  15:47:19  jaf
* Added comments about which indices of array arguments are read or
* written.
*
* Revision 1.2  1996/03/14  16:59:04  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:47:27  jaf
* Initial revision
*
*
******************************************************************
*
*   Convert Reflection Coefficients to Predictor Coeficients
*
* Inputs:
*  RC     - Reflection coefficients
*           Indices 1 through ORDER read.
*  ORDER  - Number of RC's
*  GPRIME - Excitation modification gain
* Outputs:
*  PC     - Predictor coefficients
*           Indices 1 through ORDER written.
*           Indices 1 through ORDER-1 are read after being written.
*  G2PASS - Excitation modification sharpening factor
*
* This subroutine has no local state.
*
	SUBROUTINE IRC2PC( RC, PC, ORDER, GPRIME, G2PASS )
	INCLUDE 'config.fh'

*	Arguments

	INTEGER ORDER
	REAL RC(ORDER), PC(ORDER), GPRIME, G2PASS

*       Local variables that need not be saved

	INTEGER I, J
	REAL TEMP(MAXORD)


	G2PASS = 1.
	DO I = 1,ORDER
	   G2PASS = G2PASS*( 1. - RC(I)*RC(I) )
	END DO
	G2PASS = GPRIME*SQRT(G2PASS)
	PC(1) = RC(1)
	DO I = 2,ORDER
	   DO J = 1,I-1
	      TEMP(J) = PC(J) - RC(I)*PC(I-J)
	   END DO
	   DO J = 1,I-1
	      PC(J) = TEMP(J)
	   END DO
	   PC(I) = RC(I)
	END DO
	RETURN
	END
