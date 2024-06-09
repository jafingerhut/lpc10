******************************************************************
*
*	SYNTHS Version 54
*
* $Log: synths.f,v $
* Revision 1.5  1996/03/26  19:31:58  jaf
* Commented out trace statements.
*
* Revision 1.4  1996/03/25  19:41:01  jaf
* Changed so that MAXFRM samples are always returned in the output array
* SPEECH.
*
* This required delaying the returned samples by MAXFRM sample times,
* and remembering any "left over" samples returned by PITSYN from one
* call of SYNTHS to the next.
*
* Changed size of SPEECH from 2*MAXFRM to MAXFRM.  Removed local
* variable SOUT.  Added local state variables BUF and BUFLEN.
*
* Revision 1.3  1996/03/25  19:20:10  jaf
* Added comments about the range of possible return values for argument
* K, and increased the size of the arrays filled in by PITSYN from 11 to
* 16, as has been already done inside of PITSYN.
*
* Revision 1.2  1996/03/22  00:18:18  jaf
* Added comments explaining meanings of input and output parameters, and
* indicating which array indices can be read or written.
*
* Added entry INITSYNTHS, which does nothing except call the
* corresponding initialization entries for subroutines PITSYN, BSYNZ,
* and DEEMP.
*
* Revision 1.1  1996/02/07 14:49:44  jaf
* Initial revision
*
*
******************************************************************
* 
* The note below is from the distributed version of the LPC10 coder.
* The version of the code below has been modified so that SYNTHS always
* has a constant frame length output of MAXFRM.
* 
* Also, BSYNZ and DEEMP need not be modified to work on variable
* positions within an array.  It is only necessary to pass the first
* index desired as the array argument.  What actually gets passed is the
* address of that array position, which the subroutine treats as the
* first index of the array.
* 
* This technique is used in subroutine ANALYS when calling PREEMP, so it
* appears that multiple people wrote different parts of this LPC10 code,
* and that they didn't necessarily have equivalent knowledge of Fortran
* (not surprising).
* 
*  NOTE: There is excessive buffering here, BSYNZ and DEEMP should be
*        changed to operate on variable positions within SOUT.  Also,
*        the output length parameter is bogus, and PITSYN should be
*        rewritten to allow a constant frame length output.
*
* Input:
*  VOICE  - Half frame voicing decisions
*           Indices 1 through 2 read.
* Input/Output:
*  PITCH  - Pitch
*           PITCH is restricted to range 20 to 156, inclusive,
*           before calling subroutine PITSYN, and then PITSYN
*           can modify it further under some conditions.
*  RMS    - Energy
*           Only use is for debugging, and passed to PITSYN.
*           See comments there for how it can be modified.
*  RC     - Reflection coefficients
*           Indices 1 through ORDER restricted to range -.99 to .99,
*           before calling subroutine PITSYN, and then PITSYN
*           can modify it further under some conditions.
* Output:
*  SPEECH - Synthesized speech samples.
*           Indices 1 through the final value of K are written.
*  K      - Number of samples placed into array SPEECH.
*           This is always MAXFRM.
*           
	SUBROUTINE SYNTHS(VOICE, PITCH, RMS, RC, SPEECH, K)
	INCLUDE 'config.fh'
	INCLUDE 'contrl.fh'

*       Arguments

	INTEGER VOICE(2), PITCH
	REAL RMS, RC(ORDER), SPEECH(MAXFRM)
	INTEGER K

*       Parameters/constants

	REAL GPRIME
	PARAMETER (GPRIME = .7)
	INTEGER TWOFRM
	PARAMETER (TWOFRM = 2*MAXFRM)

*       Local variables that need not be saved

	INTEGER I, J, NOUT
	REAL RATIO, G2PASS
	REAL PC(MAXORD)
	INTEGER IPITI(16), IVUV(16)
	REAL RCI(MAXORD,16), RMSI(16)

*       Local state

*       BUF is a buffer of speech samples that would have been returned
*       by the older version of SYNTHS, but the newer version doesn't,
*       so that the newer version can always return MAXFRM samples on
*       every call.  This has the effect of delaying the return of
*       samples for one additional frame time.
*       
*       Indices 1 through BUFLEN contain samples that are left over from
*       the last call to SYNTHS.  Given the way that PITSYN works,
*       BUFLEN should always be in the range MAXFRM-MAXPIT+1 through
*       MAXFRM, inclusive, after a call to SYNTHS is complete.
*       
*       On the first call to SYNTHS (or the first call after
*       reinitializing with the entry INITSYNTHS), BUFLEN is MAXFRM, and
*       a frame of silence is always returned.

	REAL BUF(TWOFRM)
	INTEGER BUFLEN

	SAVE BUF, BUFLEN

	DATA BUF /TWOFRM*0./, BUFLEN /MAXFRM/


*	IF (LISTL.GE.3) THEN
*	   WRITE(FDEBUG,400) NFRAME, VOICE, PITCH, RMS, RC
*400	   FORMAT(1X/' SYNTHESIS DATA -- FRAME',I6,
*     1    T32,2I3,I6,1X,F5.0,10F8.3/)
*	   IF (LISTL.GE.4) WRITE(FDEBUG,410)
*410	   FORMAT(' EPOCH  G2PASS  RATIO PSCALE')
*	END IF

	pitch = max(min(pitch,156),20)
	do i = 1, order
	    rc(i) = max(min(rc(i),.99),-.99)
	end do

	CALL PITSYN(ORDER, VOICE, PITCH, RMS, RC, LFRAME, 
     1              IVUV, IPITI, RMSI, RCI, NOUT, RATIO)
	IF (NOUT.GT.0) THEN
	   DO J = 1,NOUT
*             
*             Add synthesized speech for pitch period J to the end of
*             BUF.
*             

*	      IF (LISTL.GE.3) THEN
*	         IF (LISTL.EQ.3) THEN
*	            WRITE(FDEBUG,420) J, NOUT, IVUV(J), IPITI(J), RMSI(J),
*     1             (RCI(I,J),I=1,ORDER)
*420	            FORMAT(1X,'PITSYN EPOCH ',I2,' OF ',I2,T32,I4,I8,1X,
*     1             F5.0,T50,10F8.3)
*	         ELSE
*	            WRITE(FDEBUG,422) J, NOUT, IVUV(J), IPITI(J), RMSI(J),
*     1             (RCI(I,J),I=1,ORDER)
*422	            FORMAT(1X,I2,'/',I2,T32,I4,I8,1X,
*     1             F5.0,T50,10F8.3)
*	         END IF
*	      END IF

	      CALL IRC2PC(RCI(1,J), PC, ORDER, GPRIME, G2PASS)

*	      IF (LISTL.GE.4) WRITE(FDEBUG,430) G2PASS, RATIO, 1.0, PC
*430	      FORMAT(T7,3F7.3,T50,10F8.1)

	      CALL BSYNZ(PC, IPITI(J), IVUV(J), BUF(BUFLEN+1), RMSI(J),
     1       RATIO, G2PASS)
	      CALL DEEMP(BUF(BUFLEN+1), IPITI(J))
	      BUFLEN = BUFLEN + IPITI(J)
	   END DO
*          
*          Copy first MAXFRM samples from BUF to output array SPEECH
*          (scaling them), and then remove them from the beginning of
*          BUF.
*          
	   DO I = 1,MAXFRM
	      SPEECH(I) = BUF(I) / 4096.
	   END DO
	   K = MAXFRM
	   BUFLEN = BUFLEN - MAXFRM
	   DO I = 1,BUFLEN
	      BUF(I) = BUF(MAXFRM+I)
	   END DO
	END IF

	RETURN


	ENTRY INITSYNTHS ()

	DO I = 1,TWOFRM
	   BUF(I) = 0.
	END DO
	BUFLEN = MAXFRM

* Initialize local state inside of the following subroutines.

	CALL INITPITSYN ()
	CALL INITBSYNZ ()
	CALL INITDEEMP ()

	RETURN

	END
