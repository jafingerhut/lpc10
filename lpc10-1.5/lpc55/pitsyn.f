******************************************************************
*
*	PITSYN Version 53
*
* $Log: pitsyn.f,v $
* Revision 1.2  1996/03/25  18:49:07  jaf
* Added commments about which indices of array arguments are read or
* written.
*
* Rearranged local variable declarations to indicate which need to be
* saved from one invocation to the next.  Added entry INITPITSYN to
* reinitialize local state variables, if desired.
*
* Added lots of comments about proving that the maximum number of pitch
* periods (NOUT) that can be returned is 16.  The call to STOP that
* could happen if NOUT got too large was removed as a result.
*
* Also proved that the total number of samples returned from N calls,
* each with identical values of LFRAME, will always be in the range
* N*LFRAME-MAXPIT+1 to N*LFRAME.
*
* Revision 1.1  1996/02/07 14:48:18  jaf
* Initial revision
*
*
******************************************************************
*
*   Synthesize a single pitch epoch
*
* Input:
*  ORDER  - Synthesis order (number of RC's)
*  VOICE  - Half frame voicing decisions
*           Indices 1 through 2 read.
*  LFRAME - Length of speech buffer
* Input/Output:
*  PITCH  - Pitch
*           This value should be in the range MINPIT (20) to MAXPIT
*           (156), inclusive.
*           PITCH can be modified under some conditions.
*  RMS    - Energy  (can be modified)
*           RMS is changed to 1 if the value passed in is less than 1.
*  RC     - Reflection coefficients
*           Indices 1 through ORDER can be temporarily overwritten with
*           RCO, and then replaced with original values, under some
*           conditions.
* Output:
*  IVUV   - Pitch epoch voicing decisions
*           Indices (I) of IVUV, IPITI, and RMSI are written,
*           and indices (J,I) of RCI are written,
*           where I ranges from 1 to NOUT, and J ranges from 1 to ORDER.
*  IPITI  - Pitch epoch length
*  RMSI   - Pitch epoch energy
*  RCI    - Pitch epoch RC's
*  NOUT   - Number of pitch periods in this frame
*           This is at least 0, at least 1 if MAXPIT .LT. LFRAME (this
*           is currently true on every call), and can never be more than
*           (LFRAME+MAXPIT-1)/PITCH, which is currently 16 with
*           LFRAME=180, MAXPIT=156, and PITCH .GE. 20, as SYNTHS
*           guarantees when it calls this subroutine.
*  RATIO  - Previous to present energy ratio
*           Always assigned a value.
*  
	SUBROUTINE PITSYN( ORDER, VOICE, PITCH, RMS, RC, LFRAME,
     1  		   IVUV, IPITI, RMSI, RCI, NOUT, RATIO )
	INCLUDE 'config.fh'

*       Arguments

	INTEGER ORDER, VOICE(2), PITCH
	REAL RMS, RC(ORDER)
	INTEGER LFRAME
	INTEGER IVUV(16), IPITI(16)
	REAL RMSI(16), RCI(ORDER,16)
	INTEGER NOUT
	REAL RATIO

*       Local variables that need not be saved

*       LSAMP is initialized in the IF (FIRST) THEN clause, but it is
*       not used the first time through, and it is given a value before
*       use whenever FIRST is .FALSE., so it appears unnecessary to
*       assign it a value when FIRST is .TRUE.

	INTEGER I, J, LSAMP, IP, ISTART, IVOICE
	INTEGER JUSED, NL
	REAL ALRN, ALRO, PROP
	REAL SLOPE, UVPIT, XXY
	INTEGER VFLAG
	REAL YARC(MAXORD)

*       Local state

* FIRST  - .TRUE. only on first call to PITSYN.
* IVOICO - Previous VOICE(2) value.
* IPITO  - Previous PITCH value.
* RMSO   - Previous RMS value.
* RCO    - Previous RC values.
* 
* JSAMP  - If this routine is called N times with identical values of
*          LFRAME, then the total length of all pitch periods returned
*          is always N*LFRAME-JSAMP, and JSAMP is always in the range 0
*          to MAXPIT-1 (see below for why this is so).  Thus JSAMP is
*          the number of samples "left over" from the previous call to
*          PITSYN, that haven't been "used" in a pitch period returned
*          from this subroutine.  Every time this subroutine is called,
*          it returns pitch periods with a total length of at most
*          LFRAME+JSAMP.
*          
* IVOICO, IPITO, RCO, and JSAMP need not be assigned an initial value
* with a DATA statement, because they are always initialized on the
* first call to PITSYN.
*          
* FIRST and RMSO should be initialized with DATA statements, because
* even on the first call, they are used before being initialized.

	INTEGER IVOICO, IPITO
	REAL RMSO
	REAL RCO(MAXORD)
	INTEGER JSAMP
	LOGICAL FIRST

	SAVE IVOICO, IPITO, RMSO, RCO, JSAMP, FIRST

	DATA RMSO /1./
	DATA FIRST /.TRUE./


	IF (RMS .LT. 1) RMS = 1
	IF (RMSO .LT. 1) RMSO = 1
	UVPIT = 0.0
	RATIO = RMS/(RMSO+8.)
	IF (FIRST) THEN
	   LSAMP = 0
	   IVOICE = VOICE(2)
	   IF (IVOICE .EQ. 0) PITCH = LFRAME/4
	   NOUT = LFRAME/PITCH
	   JSAMP = LFRAME - NOUT*PITCH
*          
*          SYNTHS only calls this subroutine with PITCH in the range 20
*          to 156.  LFRAME = MAXFRM = 180, so NOUT is somewhere in the
*          range 1 to 9.
*          
*          JSAMP is "LFRAME mod PITCH", so it is in the range 0 to
*          (PITCH-1), or 0 to MAXPIT-1=155, after the first call.
*          
	   DO I = 1,NOUT
	      DO J = 1,ORDER
	         RCI(J,I) = RC(J)
	      END DO
	      IVUV(I) = IVOICE
	      IPITI(I) = PITCH
	      RMSI(I) = RMS
	   END DO
	   FIRST = .FALSE.
	ELSE
	   VFLAG = 0
	   LSAMP = LFRAME + JSAMP
	   SLOPE = (PITCH-IPITO)/FLOAT(LSAMP)
	   NOUT = 0
	   JUSED = 0
	   ISTART = 1
	   IF ((VOICE(1) .EQ. IVOICO) .AND. (VOICE(2) .EQ. VOICE(1))) THEN
	      IF (VOICE(2) .EQ. 0) THEN
* SSUV - -   0  ,  0  ,  0
	         PITCH = LFRAME/4
	         IPITO = PITCH
	         IF (RATIO .GT. 8) RMSO = RMS
	      END IF
* SSVC - -   1  ,  1  ,  1
	      SLOPE = (PITCH-IPITO)/FLOAT(LSAMP)
	      IVOICE = VOICE(2)
	   ELSE
	      IF (IVOICO .NE. 1) THEN
	         IF (IVOICO .EQ. VOICE(1)) THEN
* UV2VC2 - -  0  ,  0  ,  1
	            NL = LSAMP - LFRAME/4
	         ELSE
* UV2VC1 - -  0  ,  1  ,  1
	            NL = LSAMP - 3*LFRAME/4
	         ENDIF
	         IPITI(1) = NL/2
	         IPITI(2) = NL - IPITI(1)
	         IVUV(1) = 0
	         IVUV(2) = 0
	         RMSI(1) = RMSO
	         RMSI(2) = RMSO
	         DO I = 1,ORDER
	            RCI(I,1) = RCO(I)
	            RCI(I,2) = RCO(I)
	            RCO(I)   = RC(I)
	         END DO
	         SLOPE = 0
	         NOUT = 2
	         IPITO = PITCH
	         JUSED = NL
	         ISTART = NL + 1
	         IVOICE = 1
	      ELSE
	         IF (IVOICO .NE. VOICE(1)) THEN
* VC2UV1 - -   1  ,  0  ,  0
	            LSAMP = LFRAME/4 + JSAMP
	         ELSE
* VC2UV2 - -   1  ,  1  ,  0
	            LSAMP = 3*LFRAME/4 + JSAMP
	         END IF
	         DO I = 1,ORDER
	            YARC(I) = RC(I)
	            RC(I) = RCO(I)
	         END DO
	         IVOICE = 1
	         SLOPE = 0.
	         VFLAG = 1
	      END IF
	   END IF

* Here is the value of most variables that are used below, depending on
* the values of IVOICO, VOICE(1), and VOICE(2).  VOICE(1) and VOICE(2)
* are input arguments, and IVOICO is the value of VOICE(2) on the
* previous call (see notes for the IF (NOUT .NE. 0) statement near the
* end).  Each of these three values is either 0 or 1.  These three
* values below are given as 3-bit long strings, in the order IVOICO,
* VOICE(1), and VOICE(2).  It appears that the code above assumes that
* the bit sequences 010 and 101 never occur, but I wonder whether a
* large enough number of bit errors in the channel could cause such a
* thing to happen, and if so, could that cause NOUT to ever go over 11?
* 
* Note that all of the 180 values in the table are really LFRAME, but
* 180 has fewer characters, and it makes the table a little more
* concrete.  If LFRAME is ever changed, keep this in mind.  Similarly,
* 135's are 3*LFRAME/4, and 45's are LFRAME/4.  If LFRAME is not a
* multiple of 4, then the 135 for NL-JSAMP is actually LFRAME-LFRAME/4,
* and the 45 for NL-JSAMP is actually LFRAME-3*LFRAME/4.
* 
* Note that LSAMP-JSAMP is given as the variable.  This was just for
* brevity, to avoid adding "+JSAMP" to all of the column entries.
* Similarly for NL-JSAMP.
* 
* Variable    | 000  001    011,010  111       110       100,101
* ------------+--------------------------------------------------
* ISTART      | 1    NL+1   NL+1     1         1         1
* LSAMP-JSAMP | 180  180    180      180       135       45
* IPITO       | 45   PITCH  PITCH    oldPITCH  oldPITCH  oldPITCH
* SLOPE       | 0    0      0        seebelow  0         0
* JUSED       | 0    NL     NL       0         0         0
* PITCH       | 45   PITCH  PITCH    PITCH     PITCH     PITCH
* NL-JSAMP    | --   135    45       --        --        --
* VFLAG       | 0    0      0        0         1         1
* NOUT        | 0    2      2        0         0         0
* IVOICE      | 0    1      1        1         1         1
* 
* while_loop  | once once   once     once      twice     twice
* 
* ISTART      | --   --     --       --        JUSED+1   JUSED+1
* LSAMP-JSAMP | --   --     --       --        180       180
* IPITO       | --   --     --       --        oldPITCH  oldPITCH
* SLOPE       | --   --     --       --        0         0
* JUSED       | --   --     --       --        ??        ??
* PITCH       | --   --     --       --        PITCH     PITCH
* NL-JSAMP    | --   --     --       --        --        --
* VFLAG       | --   --     --       --        0         0
* NOUT        | --   --     --       --        ??        ??
* IVOICE      | --   --     --       --        0         0
* 
* 
* UVPIT is always 0.0 on the first pass through the DO WHILE (.TRUE.)
* loop below.
* 
* The only possible non-0 value of SLOPE (in column 111) is
* (PITCH-IPITO)/FLOAT(LSAMP)
* 
* Column 101 is identical to 100.  Any good properties we can prove
* for 100 will also hold for 101.  Similarly for 010 and 011.
* 
* SYNTHS calls this subroutine with PITCH restricted to the range 20 to
* 156.  IPITO is similarly restricted to this range, after the first
* call.  IP below is also restricted to this range, given the
* definitions of IPITO, SLOPE, UVPIT, and that I is in the range ISTART
* to LSAMP.
* 
	   DO WHILE (.TRUE.)
*             
*             JUSED is the total length of all pitch periods currently
*             in the output arrays, in samples.
*             
*             An invariant of the DO I = ISTART,LSAMP loop below, under
*             the condition that IP is always in the range 1 through
*             MAXPIT, is:
*             
*             (I - MAXPIT) .LE. JUSED .LE. (I-1)
*             
*             Note that the final value of I is LSAMP+1, so that after
*             the DO loop is complete, we know:
*             
*             (LSAMP - MAXPIT + 1) .LE. JUSED .LE. LSAMP
*             
	      DO I = ISTART,LSAMP
	         IP = IPITO + SLOPE*I + .5
	         IF (UVPIT .NE. 0.0) IP = UVPIT
	         IF (IP .LE. I-JUSED) THEN
	            NOUT = NOUT + 1
*                   
*                   The following check is no longer necessary, now that
*                   we can prove that NOUT will never go over 16.
*                   
*		    IF (NOUT .GT. 16) STOP 'PITSYN: too many epochs'
*                   
	            IPITI(NOUT) = IP
	            PITCH = IP
	            IVUV(NOUT) = IVOICE
	            JUSED = JUSED + IP
	            PROP = (JUSED-IP/2)/FLOAT(LSAMP)
	            DO J = 1,ORDER
	               ALRO = ALOG((1+RCO(J))/(1-RCO(J)))
	               ALRN = ALOG((1+RC(J))/(1-RC(J)))
	               XXY = ALRO + PROP*(ALRN-ALRO)
	               XXY = EXP(XXY)
	               RCI(J,NOUT) = (XXY-1)/(XXY+1)
	            END DO
	            RMSI(NOUT) = ALOG(RMSO) + PROP*(ALOG(RMS)-ALOG(RMSO))
	            RMSI(NOUT) = EXP(RMSI(NOUT))
	         END IF
	      END DO
	      IF (VFLAG .NE. 1) GOTO 100
*             
*             I want to prove what range UVPIT must lie in after the
*             assignments to it below.  To do this, I must determine
*             what range (LSAMP-ISTART) must lie in, after the
*             assignments to ISTART and LSAMP below.
*             
*             Let oldLSAMP be the value of LSAMP at this point in the
*             execution.  This is 135+JSAMP in state 110, or 45+JSAMP in
*             states 100 or 101.
*             
*             Given the loop invariant on JUSED above, we know that:
*             
*             (oldLSAMP - MAXPIT + 1) .LE. JUSED .LE. oldLSAMP
*             
*             ISTART is one more than this.
*             
*             Let newLSAMP be the value assigned to LSAMP below.  This
*             is 180+JSAMP.  Thus (newLSAMP-oldLSAMP) is either 45 or
*             135, depending on the state.
*             
*             Thus, the range of newLSAMP-ISTART is:
*             
*             (newLSAMP-(oldLSAMP+1)) .LE. newLSAMP-ISTART
*             .LE. (newLSAMP-(oldLSAMP - MAXPIT + 2))
*             
*             or:
*             
*             46 .LE. newLSAMP-ISTART .LE. 133+MAXPIT .EQ. 289
*             
*             Therefore, UVPIT is in the range 23 to 144 after the first
*             assignment to UVPIT below, and after the conditional
*             assignment, it is in the range 23 to 90.
*             
*             The important thing is that it is in the range 20 to 156,
*             so that in the loop above, IP is always in this range.
*             
	      VFLAG = 0
	      ISTART = JUSED + 1
	      LSAMP = LFRAME + JSAMP
	      SLOPE = 0
	      IVOICE = 0
	      UVPIT = (LSAMP-ISTART)/2
	      IF (UVPIT .GT. 90) UVPIT = UVPIT/2
	      RMSO = RMS
	      DO I = 1,ORDER
	         RC(I) = YARC(I)
	         RCO(I) = YARC(I)
	      END DO
	   END DO
100	   JSAMP = LSAMP - JUSED
	END IF

*       Given that the maximum pitch period MAXPIT .LT. LFRAME (this is
*       currently true on every call, since SYNTHS always sets
*       LFRAME=180), NOUT will always be .GE. 1 at this point.

	IF (NOUT .NE. 0) THEN
	   IVOICO = VOICE(2)
	   IPITO = PITCH
	   RMSO = RMS
	   DO I = 1,ORDER
	      RCO(I) = RC(I)
	   END DO
	END IF
	RETURN


	ENTRY INITPITSYN ()

	RMSO = 1.
	FIRST = .TRUE.

	RETURN

	END
