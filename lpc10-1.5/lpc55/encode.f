******************************************************************
*
*	ENCODE Version 54
*
* $Log: encode.f,v $
* Revision 1.5  1996/03/26  19:35:50  jaf
* Commented out trace statements.
*
* Revision 1.4  1996/03/21  00:26:29  jaf
* Added the comment that this subroutine has no local state.
*
* In the last check-in, I forgot to mention that I had added comments
* explaining which indices of array arguments are read or written.
*
* Revision 1.3  1996/03/21  00:22:39  jaf
* Added comments explaining that all local arrays are effectively
* constants.
*
* Revision 1.2  1996/03/13  18:48:33  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:45:29  jaf
* Initial revision
*
*
******************************************************************
*
*  Quantize LPC parameters for transmission
*
* INPUTS:
*  VOICE  - Half frame voicing decisions
*           Indices 1 through 2 read.
*  PITCH  - Pitch
*  RMS    - Energy
*  RC     - Reflection coefficients
*           Indices 1 through ORDER read.
*  CORRP  - Error Correction: TRUE = yes, FALSE = none
*           (this is defined in file control.fh)
* OUTPUTS:
*  IPITCH - Coded pitch and voicing
*  IRMS   - Quantized energy
*  IRC    - Quantized reflection coefficients
*           Indices 1 through MAX(ORDER,2) written.
*           If CORRP is .TRUE., then indices 1 through 10 written
*           for unvoiced frames.
*
* This subroutine has no local state.
*
	SUBROUTINE ENCODE(VOICE, PITCH, RMS, RC,
     1                    IPITCH, IRMS, IRC )
	INCLUDE 'config.fh'
	INCLUDE 'contrl.fh'

*       Arguments

	INTEGER VOICE(2), PITCH
	REAL RMS, RC(ORDER)
	INTEGER IPITCH, IRMS, IRC(ORDER)

*       Parameters/constants

*       These arrays are not Fortran PARAMETER's, but they are defined
*       by DATA statements below, and their contents are never altered.

	INTEGER ENCTAB(16), ENTAB6(64), RMST(64)
	INTEGER ENTAU(60), ENBITS(8), ENADD(8)
	REAL ENSCL(8)

*       Local variables that need not be saved

	INTEGER I, J, I2, I3, MRK, NBIT, IDEL

	DATA ENCTAB/0,7,11,12,13,10,6,1,14,9,5,2,3,4,8,15/
	DATA ENTAU/19,11,27,25,29,21,23,22,30,14,15,7,39,
     1  	38,46,42,43,41,45,37,53,49,51,50,54,52,
     1  	60,56,58,26,90,88,92,84,86,82,83,81,85,
     1  	69,77,73,75,74,78,70,71,67,99,97,113,112,
     1  	114,98,106,104,108,100,101,76/
	DATA ENADD/1920,-768,2432,1280,3584,1536,2816,-1152/
	DATA ENSCL/.0204,.0167,.0145,.0147,.0143,.0135,.0125,.0112/
	DATA ENBITS/6,5,4,4,4,4,3,3/
	DATA ENTAB6/6*0,7*1,7*2,7*3,7*4,5*5,5*6,5*7,4*8,
     1  	3*9,2*10,2*11,12,13,14,15/
	DATA RMST/1024,936,856,784,718,656,600,550,
     1  	502,460,420,384,352,328,294,270,
     1  	246,226,206,188,172,158,144,132,
     1  	120,110,102,92,84,78,70,64,
     1  	60,54,50,46,42,38,34,32,
     1  	30,26,24,22,20,18,17,16,
     1  	15,14,13,12,11,10,9,8,
     1  	7,6,5,4,3,2,1,0/

*  Scale RMS and RC's to integers

	IRMS = RMS
	DO I = 1,ORDER
	   IRC(I) = RC(I) * 2.**15
	END DO
	
*	IF(LISTL.GE.3)WRITE(FDEBUG,800)VOICE,PITCH,IRMS,(IRC(I),I=1,ORDER)
*800	FORMAT(1X,/,' <<ENCODE IN>>',T32,2I3,I6,I5,T50,10I8)

*  Encode pitch and voicing

	IF(VOICE(1).NE.0.AND.VOICE(2).NE.0) THEN
	   IPITCH = ENTAU(PITCH)
	ELSE
	   IF(CORRP) THEN
	      IPITCH = 0
	      IF(VOICE(1).NE.VOICE(2)) IPITCH = 127
	   ELSE
	      IPITCH = 2*VOICE(1) + VOICE(2)
	   END IF
	END IF

*  Encode RMS by binary table search

	J = 32
	IDEL = 16
	IRMS = MIN(IRMS,1023)
	DO WHILE(IDEL.GT.0)
	   IF (IRMS.GT.RMST(J)) J = J - IDEL
	   IF (IRMS.LT.RMST(J)) J = J + IDEL
	   IDEL = IDEL/2
	END DO
	IF (IRMS.GT.RMST(J)) J = J - 1
	IRMS = 31 - J/2

*  Encode RC(1) and (2) as log-area-ratios

	DO I = 1,2
	   I2 = IRC(I)
	   MRK = 0
	   IF(I2.LT.0) THEN
	      I2 = -I2
	      MRK = 1
	   END IF
	   I2 = I2/(2**9)
	   I2 = MIN(I2,63)
	   I2 = ENTAB6(I2+1)
	   IF(MRK.NE.0) I2 = -I2
	   IRC(I) = I2
	END DO

*  Encode RC(3) - (10) linearly, remove bias then scale

	DO I = 3,ORDER
	   I2 = IRC(I)/2
	   I2 = (I2+ENADD(ORDER+1-I))*ENSCL(ORDER+1-I)
	   I2 = MIN(MAX(I2,-127),127)
	   NBIT = ENBITS(ORDER+1-I)
	   I3 = 0
	   IF(I2.LT.0) I3 = -1
	   I2 = I2/(2**NBIT)
	   IF(I3.EQ.-1) I2 = I2-1
	   IRC(I) = I2
	END DO

*          Protect the most significant bits of the most
*     important parameters during non-voiced frames.
*     RC(1) - RC(4) are protected using 20 parity bits
*     replacing RC(5) - RC(10).

	IF(CORRP) THEN
	   IF(IPITCH.EQ.0.OR.IPITCH.EQ.127) THEN
	      IRC(5) = ENCTAB(AND(IRC(1),30)/2+1)
	      IRC(6) = ENCTAB(AND(IRC(2),30)/2+1)
	      IRC(7) = ENCTAB(AND(IRC(3),30)/2+1)
	      IRC(8) = ENCTAB(AND(IRMS,30)/2+1)
	      IRC(9) = (ENCTAB(AND(IRC(4),30)/2+1))/2
	      IRC(10)= AND(ENCTAB(AND(IRC(4),30)/2+1),1)
	   END IF
	END IF

*	IF(LISTL.GE.3)WRITE(FDEBUG,801)VOICE,IPITCH,IRMS,(IRC(J),J=1,ORDER)
*801	FORMAT(1X,'<<ENCODE OUT>>',T32,2I3,I6,I5,T50,10I8)
	RETURN
	END
