**********************************************************************
*
*	MEDIAN Version 45G
*
* $Log: median.f,v $
* Revision 1.2  1996/03/14  22:30:22  jaf
* Just rearranged the comments and local variable declarations a bit.
*
* Revision 1.1  1996/02/07 14:47:53  jaf
* Initial revision
*
*
**********************************************************************
*
*  Find median of three values
*
* Input:
*  D1,D2,D3 - Three input values
* Output:
*  MEDIAN - Median value
*
	FUNCTION MEDIAN( D1, D2, D3 )
	INTEGER MEDIAN

*       Arguments

	INTEGER D1, D2, D3

	MEDIAN = D2
	IF    ( D2 .GT. D1 .AND. D2 .GT. D3 ) THEN
	   MEDIAN = D1
	   IF ( D3 .GT. D1 ) MEDIAN = D3
	ELSEIF( D2 .LT. D1 .AND. D2 .LT. D3 ) THEN
	   MEDIAN = D1
	   IF ( D3 .LT. D1 ) MEDIAN = D3
	END IF

	RETURN
	END
