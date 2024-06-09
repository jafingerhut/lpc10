*******************************************************************
*
*	PLACEV Version 48
*
* $Log: placev.f,v $
* Revision 1.6  1996/03/19  20:42:19  jaf
* Added some conditions satisfied by the output values in VWIN.
*
* Revision 1.5  1996/03/19  18:37:56  jaf
* Strengthened the specification of which indices of VWIN are read and
* written.
*
* Revision 1.4  1996/03/15  16:38:33  jaf
* One tiny comment added.
*
* Revision 1.3  1996/03/15  16:36:13  jaf
* Added comments giving In/Out status of arguments.
*
* Revision 1.2  1996/03/12  23:56:01  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:48:39  jaf
* Initial revision
*
*
*******************************************************************


*
* Input:
*  OSBUF	Buffer which holds sorted indexes of onsets
*       	I believe that only indices 1 through OSPTR-1 can be read.
*  OSLEN
*  OSPTR	Free pointer into OSBUF
*  AF
*  LFRAME
*  MINWIN
*  MAXWIN
*  DVWINL
*  DVWINH	(This argument is never used.  Should it be?)
* Input/Output:
*  VWIN		Buffer of Voicing Window Positions (Modified)
*       	Index (2,AF-1) is read.
*       	Indices (1,AF) and (2,AF) are written,
*       	and then possibly read.
*       	All other indices are unused.
*               In all cases, the final values will satsify the condition:
*               VWIN(2,AF)-VWIN(1,AF)+1 .LE. MAXWIN
*               I'm not certain yet, but they may also satisfy:
*               MINWIN .LE. VWIN(2,AF)-VWIN(1,AF)+1
* Output:
*  OBOUND	This variable is set by this procedure and used
*		in placing analysis windows (PLACEA).  Bit 1
*		indicates whether an onset bounds the left side
*		of the voicing window, and bit 2 indicates whether
*		an onset bounds the right side of the voicing window.
*
* This subroutine has no local state.
*

	SUBROUTINE PLACEV( OSBUF, OSPTR, OSLEN, OBOUND, VWIN, AF,
     1   LFRAME, MINWIN, MAXWIN, DVWINL, DVWINH )

*       Arguments

	INTEGER OSLEN, OSBUF(OSLEN), OSPTR, OBOUND, AF, VWIN(2,AF)
	INTEGER LFRAME, MINWIN, MAXWIN, DVWINL, DVWINH

*       Local variables that need not be saved

*   Variables
*    LRANGE, HRANGE  Range in which window is placed
*    OSPTR1     OSPTR excluding samples in 3F

	INTEGER LRANGE, HRANGE, I, Q, OSPTR1
	LOGICAL CRIT

*       Local state

*       None


*   Voicing Window Placement
*
*         __________________ __________________ ______________
*        |                  |                  |
*        |        1F        |        2F        |        3F ...
*        |__________________|__________________|______________
*
*    Previous |
*      Window |
*  ...________|
*
*             |                                |
*      ------>| This window's placement range  |<------
*             |                                |
*
*   There are three cases.  Note that these are different from those
*   given in the LPC-10e phase 1 report.
*
*   1.  If there are no onsets in this range, then the voicing window
*   is centered in the pitch window.  If such a placement is not within
*   the window's placement range, then the window is placed in the left-
*   most portion of the placement range.  Its length is always MAXWIN.
*
*   2.  If the first onset is in 2F and there is sufficient room to place
*   the window immediately before this onset, then the window is placed
*   there, and its length is set to the maximum possible under these
*   constraints.
*
*	"Critical Region Exception":  If there is another onset in 2F
*	such that a window can be placed between the two onsets, the
*	window is placed there (ie, as in case 3).
*
*   3.  Otherwise, the window is placed immediately after the onset.  The 
*   window's length
*   is the longest length that can fit in the range under these constraints,
*   except that the window may be shortened even further to avoid overlapping
*   other onsets in the placement range.  In any case, the window's length
*   is at least MINWIN.
*
*   Note that the values of MINWIN and LFRAME must be chosen such
*   that case 2 = false implies case 3 = true.   This means that
*   MINWIN <= LFRAME/2.  If this were not the case, then a fourth case
*   would have to be added for when the window cannot fit either before
*   or after the onset.
*
*   Note also that onsets which weren't in 2F last time may be in 1F this
*   time, due to the filter delays in computing onsets.  The result is that
*   occasionally a voicing window will overlap that onset.  The only way
*   to circumvent this problem is to add more delay in processing input
*   speech.  In the trade-off between delay and window-placement, window
*   placement lost.

* Compute the placement range

	LRANGE = MAX(VWIN(2,AF-1)+1, (AF-2)*LFRAME+1)
	HRANGE = AF*LFRAME

* Compute OSPTR1, so the following code only looks at relevant onsets.

	DO OSPTR1 = OSPTR-1, 1, -1
	   IF (OSBUF (OSPTR1) .LE. HRANGE) GOTO 90
	END DO
90	OSPTR1 = OSPTR1 + 1

* Check for case 1 first (fast case):

	IF ((OSPTR1 .LE. 1) .OR. (OSBUF(OSPTR1-1) .LT. LRANGE)) THEN
	   VWIN(1,AF) = MAX(VWIN(2,AF-1)+1, DVWINL)
	   VWIN(2,AF) = VWIN(1,AF) + MAXWIN - 1
	   OBOUND = 0
	ELSE

* Search backward in OSBUF for first onset in range.
* This code relies on the above check being performed first.

	   DO Q = OSPTR1-1, 1, -1
	      IF (OSBUF(Q) .LT. LRANGE) GOTO 100
	   END DO
100	   Q = Q + 1

* Check for case 2 (placement before onset):

* Check for critical region exception:

	   DO I = Q+1, OSPTR1-1
	      IF (OSBUF(I) - OSBUF(Q) .GE. MINWIN) THEN
	         CRIT = .TRUE.
	         GOTO 105
	      END IF
	   END DO
	   CRIT = .FALSE.
105	   CONTINUE

	   IF (.NOT. CRIT .AND.
     1        OSBUF(Q) .GT. MAX((AF-1)*LFRAME, LRANGE+MINWIN-1)) THEN
	      VWIN(2,AF) = OSBUF(Q) - 1
	      VWIN(1,AF) = MAX (LRANGE, VWIN(2,AF)-MAXWIN+1)
	      OBOUND = 2

* Case 3 (placement after onset)

	   ELSE
	      VWIN(1,AF) = OSBUF(Q)
110	      Q = Q + 1
	      IF (Q .GE. OSPTR1) GO TO 120
	      IF (OSBUF(Q) .GT. VWIN(1,AF) + MAXWIN) GO TO 120
	      IF (OSBUF(Q) .LT. VWIN(1,AF) + MINWIN) GO TO 110
	      VWIN(2,AF) = OSBUF(Q) - 1
	      OBOUND = 3
	      RETURN
120	      VWIN(2,AF) = MIN(VWIN(1,AF) + MAXWIN - 1, HRANGE)
	      OBOUND = 1
	   END IF
	END IF

	RETURN
	END
