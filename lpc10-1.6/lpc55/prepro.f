**********************************************************************
*
*	PREPRO Version 48
*
* $Log: prepro.f,v $
* Revision 1.3  1996/03/14  23:22:56  jaf
* Added comments about when INITPREPRO should be used.
*
* Revision 1.2  1996/03/14  23:09:27  jaf
* Added an entry named INITPREPRO that initializes the local state of
* this subroutine, and those it calls (if any).
*
* Revision 1.1  1996/02/07  14:48:54  jaf
* Initial revision
*
*
**********************************************************************
*
*    Pre-process input speech:
*
* Inputs:
*  LENGTH - Number of SPEECH samples
* Input/Output:
*  SPEECH(LENGTH) - Speech data.
*                   Indices 1 through LENGTH are read and modified.
* 
* This subroutine has no local state maintained from one call to the
* next, but HP100 does.  If you want to switch to using a new audio
* stream for this filter, or reinitialize its state for any other
* reason, call the ENTRY INITPREPRO.
*
	SUBROUTINE PREPRO( SPEECH, LENGTH )

*       Arguments

	INTEGER LENGTH
	REAL SPEECH(LENGTH)

*   High Pass Filter at 100 Hz

	CALL HP100( SPEECH, 1, LENGTH )

	RETURN


	ENTRY INITPREPRO ()

	CALL INITHP100()

	RETURN
	END
