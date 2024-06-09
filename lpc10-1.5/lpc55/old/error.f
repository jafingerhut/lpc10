******************************************************************
*
*	ERROR Version 45G
*
* $Log: error.f,v $
* Revision 1.2  1996/03/14  22:55:09  jaf
* Comments added explaining which of the local variables of this
* subroutine need to be saved from one invocation to the next, and which
* do not.
*
* Revision 1.1  1996/02/07 14:45:49  jaf
* Initial revision
*
*
******************************************************************
*
*  Handle LPC processing error conditions
*
*   Inputs:
*    NAME - Routine where error occurred
*    ERR  - Error code
*    INFO - Additional data
*
*  The following error codes are hardwired:
*   2 - ANALYS  Unstable RC
*   4 - DIFMAG  AMDF Overflow
*   5 - SYNTHS  Output Clipped
*   6 - BSYNZ   Synthesis Filter Overflow
*   7 -    "        "       "       "
*   8 -    "        "       "       "
*   9 - ONSET   Onset Overflow
*  10 - INVERT  RC Underflow
*  11 - INVERT  RC Overflow
*  12 -    "    "     "
*  13 -    "    "     "
*
	SUBROUTINE ERROR( NAME, ERR, INFO )
	INCLUDE 'contrl.fh'

*       Arguments

	CHARACTER NAME*(*)
	INTEGER ERR, INFO

	INTEGER MAXERR
	PARAMETER (MAXERR=20)

*       Function return value definitions

	INTEGER LNBLNK

*       Local variables

	INTEGER M, LERR, LNF
	INTEGER MAP(MAXERR)
	CHARACTER*30 MSGT(10), MSG
	DATA MAP / 1,2,1,3,4,3*5,6,7,3*8,7*1 /
	DATA MSGT /
     1   'Undefined Error',
     1   '    Unstable RC',
     1   '  AMDF Overflow',
     1   ' Output Clipped',
     1   'Synthesis Filter Overflow',
     1   'Onset Buffer Overflow',
     1   'Underflow at RC',
     1   ' Overflow at RC',
     1   2*'Internal Inconsistency' /

	SAVE LERR, LNF

*       NO SAVE NECESSARY  M
*       NO SAVE NECESSARY  MAP, MSGT  (constant arrays)
*       NO SAVE NECESSARY  MSG

	M = ERR
	IF(M.LT.1.OR.M.GT.MAXERR) M = 1
	IF(LISTL.GE.2) THEN
	   IF(ERR.NE.LERR.OR.NFRAME.NE.LNF) THEN
	      MSG = MSGT(MAP(M))
	      WRITE(FMSG,100) NAME, ERR, NFRAME, MSG(1:LNBLNK(MSG)), INFO
100	      FORMAT(1X,A,':',T10,'Warning',I3,' at frame',I6,' - ',A,I6)
	      LINCNT = LINCNT + 1
	   END IF
	   LERR = ERR
	   LNF = NFRAME
	END IF
	IF(ERR.EQ.2) NUNSFM = NUNSFM + 1
	IF(ERR.EQ.5) ICLIP = ICLIP + INFO
	RETURN
	END
