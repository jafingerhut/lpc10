******************************************************************
*
*	DEEMP Version 48
*
* $Log: deemp.f,v $
* Revision 1.3  1996/03/20  15:54:37  jaf
* Added comments about which indices of array arguments are read or
* written.
*
* Added entry INITDEEMP to reinitialize the local state variables, if
* desired.
*
* Revision 1.2  1996/03/14  22:11:13  jaf
* Comments added explaining which of the local variables of this
* subroutine need to be saved from one invocation to the next, and which
* do not.
*
* Revision 1.1  1996/02/07 14:44:53  jaf
* Initial revision
*
*
******************************************************************
*
*  De-Emphasize output speech with   1 / ( 1 - .75z**-1 )
*    cascaded with 200 Hz high pass filter
*    ( 1 - 1.9998z**-1 + z**-2 ) / ( 1 - 1.75z**-1 + .78z**-2 )
*  
*  WARNING!  The coefficients above may be out of date with the code
*  below.  Either that, or some kind of transformation was performed
*  on the coefficients above to create the code below.
*
* Input:
*  N  - Number of samples
* Input/Output:
*  X  - Speech
*       Indices 1 through N are read before being written.
* 
* This subroutine maintains local state from one call to the next.  If
* you want to switch to using a new audio stream for this filter, or
* reinitialize its state for any other reason, call the ENTRY
* INITDEEMP.
*
	SUBROUTINE DEEMP( X, N )

*       Arguments

	INTEGER N
	REAL X(N)

*       Local variables that need not be saved

	INTEGER K
	REAL DEI0

*       Local state

*       All of the locals saved below were not given explicit initial
*       values in the original code.  I think 0 is a safe choice.

	REAL DEI1, DEI2, DEO1, DEO2, DEO3

	SAVE DEI1, DEI2, DEO1, DEO2, DEO3

	DATA DEI1/0./, DEI2/0./, DEO1/0./, DEO2/0./, DEO3/0./

	DO K = 1,N
	   DEI0 = X(K)
	   X(K) = X(K) - 1.9998*DEI1 + DEI2
     1     + 2.5*DEO1 - 2.0925*DEO2 + .585*DEO3
	   DEI2 = DEI1
	   DEI1 = DEI0
	   DEO3 = DEO2
	   DEO2 = DEO1
	   DEO1 = X(K)
	END DO

	RETURN


	ENTRY INITDEEMP ()

	DEI1 = 0.
	DEI2 = 0.
	DEO1 = 0.
	DEO2 = 0.
	DEO3 = 0.

	RETURN

	END
