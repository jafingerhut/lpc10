************************************************************************
*
*     NSA LPC-10 Voice Coder
*
*       Unix Version 54
*
*        15 March 1991
*
* $Log: lpcsim.f,v $
* Revision 1.3  1996/03/25  20:07:30  jaf
* Removed the comments added last time, and added a few different ones.
*
* Revision 1.2  1996/02/12 15:07:26  jaf
* Added a few comments.
*
* Revision 1.1  1996/02/07 14:33:03  jaf
* Initial revision
*
*
************************************************************************


	PROGRAM LPCSIM
	INCLUDE 'config.fh'
	INCLUDE 'contrl.fh'

	INTEGER VOICE(2), PITCH
	REAL RMS, RC(MAXORD), SPEECH(MAXFRM+MAXPIT)
	INTEGER LEN, N, SREAD, SWRITE
	LOGICAL EOF
	DATA  EOF /.FALSE./

*   Set processing options, open files

	CALL SETUP()

*   Process until end of file on input

	DO WHILE(.TRUE.)
	   CALL FRAME()

*   Read, Pre-process, and Analyze input speech

*       ... but only if the input file is speech (audio samples).  If
*       the input is 'parameters' or 'bits', then the reading is done in
*       the call to TRANS().

	   IF (FSI .GE. 0) THEN
	      N = SREAD(FSI, SPEECH, LFRAME)
	      IF(N .NE. LFRAME) GOTO 900
	      CALL PREPRO(SPEECH, LFRAME)
	      CALL ANALYS(SPEECH, VOICE, PITCH, RMS, RC)
	   END IF

*   Encode parameters and send over channel

	   CALL TRANS(VOICE, PITCH, RMS, RC, EOF)
	   IF(EOF) GOTO 900

*   Synthesize speech from received parameters

*       ... but only if the output file is speech (audio samples).  If
*       the output is 'parameters' or 'bits', then the writing is done
*       in the call to TRANS().

	   IF (FSO .GE. 0) THEN
	      CALL SYNTHS(VOICE, PITCH, RMS, RC, SPEECH, LEN)
*	      IF (LISTL .GE. 2) THEN
*		 WRITE(FDEBUG,100) NFRAME, LEN
*100		 FORMAT(1X,'NFRAME ',I4,' LENGTH OF DECODED FRAME ',I3)
*	      END IF
	      N = SWRITE(FSO, SPEECH, LEN)
	   END IF
	END DO

*   Finished - wrap it up

900	CALL WRAPUP()
	CALL EXIT(0)
	END
