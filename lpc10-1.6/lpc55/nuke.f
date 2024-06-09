************************************************************************
* 
* $Log: nuke.f,v $
* Revision 1.1  1996/03/31  14:02:52  jaf
* Initial revision
*
* 
************************************************************************


	PROGRAM TEST
	INCLUDE 'config.fh'
	INCLUDE 'contrl.fh'

*       Function return value definitions

        INTEGER SREAD, BITSWR

*       Local variables

	REAL SPEECH(MAXFRM)
        INTEGER BITS(54)
	INTEGER N

*   Initialize the encoder and decoder

	CALL LPCINI ()

*	NFRAME = 0

*   Process until end of file on input

	DO WHILE(.TRUE.)

*	   NFRAME = NFRAME + 1

*   Read, Pre-process, and Analyze input speech

*   Note that 0 is C file descriptor of standard input, because SREAD
*   uses C file I/O routines.

           N = SREAD(0, SPEECH, LFRAME)
           IF (N .NE. LFRAME) GOTO 900
           CALL LPCENC(SPEECH, BITS)

*   Write out coded speech as ASCII hex digits

*   Note that 6 is Fortran file unit number of standard output, because
*   BITSWR uses Fortran file I/O routines.

	   N = BITSWR(6, BITS, 54)

	END DO

*   Finished - wrap it up

900     CALL EXIT(0)
	END
