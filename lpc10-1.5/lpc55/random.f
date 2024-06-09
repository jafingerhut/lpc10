***********************************************************************
*
*	RANDOM Version 49
*
* $Log: random.f,v $
* Revision 1.3  1996/03/20  16:13:54  jaf
* Rearranged comments a little bit, and added comments explaining that
* even though there is local state here, there is no need to create an
* ENTRY for reinitializing it.
*
* Revision 1.2  1996/03/14  22:25:29  jaf
* Just rearranged the comments and local variable declarations a bit.
*
* Revision 1.1  1996/02/07 14:49:01  jaf
* Initial revision
*
*
**********************************************************************
*
*  Pseudo random number generator based on Knuth, Vol 2, p. 27.
*
* Function Return:
*  RANDOM - Integer variable, uniformly distributed over -32768 to 32767
* 
* This subroutine maintains local state from one call to the next.
* In the context of the LPC10 coder, there is no reason to reinitialize
* this local state when switching between audio streams, because its
* results are only used to generate noise for unvoiced frames.
*
	FUNCTION RANDOM ()
	INTEGER RANDOM

*	Parameters/constants

	INTEGER MIDTAP, MAXTAP
	PARAMETER (MIDTAP=2, MAXTAP=5)

*       Local state

	INTEGER J, K
	INTEGER*2 Y(MAXTAP)

	SAVE J, K, Y

	DATA J/MIDTAP/, K/MAXTAP/
	DATA Y /-21161, -8478, 30892,-10216, 16950/

*   The following is a 16 bit 2's complement addition,
*   with overflow checking disabled

	Y(K) = Y(K) + Y(J)
	RANDOM = Y(K)
	K = K - 1
	IF (K .LE. 0) K = MAXTAP
	J = J - 1
	IF (J .LE. 0) J = MAXTAP

	RETURN
	END
