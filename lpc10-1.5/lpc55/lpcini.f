******************************************************************
* 
* $Log: lpcini.f,v $
* Revision 1.1  1996/03/28  00:04:05  jaf
* Initial revision
*
* 
******************************************************************
* 
* Initialize COMMON block variables used by LPC-10 encoder and decoder,
* and call initialization routines for both of them.
* 
	SUBROUTINE LPCINI ()
	INCLUDE 'config.fh'
	INCLUDE 'contrl.fh'

	ORDER = MAXORD
	LFRAME = MAXFRM
	CORRP = .TRUE.

	CALL INITLPCENC ()
	CALL INITLPCDEC ()

*	LISTL = 6

*	IF (LISTL.GE.2) THEN
*	   OPEN(UNIT=FDEBUG, FILE='lpcdata', STATUS='unknown')
*	END IF

	RETURN
	END
