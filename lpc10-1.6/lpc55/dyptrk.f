**********************************************************************
*
*	DYPTRK Version 52
*
* $Log: dyptrk.f,v $
* Revision 1.5  1996/03/26  19:35:35  jaf
* Commented out trace statements.
*
* Revision 1.4  1996/03/19  18:03:22  jaf
* Replaced the initialization "DATA P/60*DEPTH*0/" with "DATA P/120*0/",
* because apparently Fortran (or at least f2c) can't handle expressions
* like that.
*
* Revision 1.3  1996/03/19  17:38:32  jaf
* Added comments about the local variables that should be saved from one
* invocation to the next.  None of them were given initial values in the
* original code, but from my testing, it appears that initializing them
* all to 0 works.
*
* Added entry INITDYPTRK to reinitialize these local variables.
*
* Revision 1.2  1996/03/13  16:32:17  jaf
* Comments added explaining which of the local variables of this
* subroutine need to be saved from one invocation to the next, and which
* do not.
*
* WARNING!  Some of them that should are never given initial values in
* this code.  Hopefully, Fortran 77 defines initial values for them, but
* even so, giving them explicit initial values is preferable.
*
* Revision 1.1  1996/02/07 14:45:14  jaf
* Initial revision
*
*
**********************************************************************
*
*   Dynamic Pitch Tracker
*
* Input:
*  AMDF   - Average Magnitude Difference Function array
*           Indices 1 through LTAU read, and MINPTR
*  LTAU   - Number of lags in AMDF
*  MINPTR - Location of minimum AMDF value
*  VOICE  - Voicing decision
* Output:
*  PITCH  - Smoothed pitch value, 2 frames delayed
*  MIDX   - Initial estimate of current frame pitch
* Compile time constant:
*  DEPTH  - Number of frames to trace back
* 
* This subroutine maintains local state from one call to the next.  If
* you want to switch to using a new audio stream for this filter, or
* reinitialize its state for any other reason, call the ENTRY
* INITDYPTRK.
*

	SUBROUTINE DYPTRK( AMDF, LTAU, MINPTR, VOICE, PITCH, MIDX )
	INCLUDE 'contrl.fh'

*       Arguments

	INTEGER LTAU, MINPTR, VOICE, PITCH, MIDX
	REAL AMDF(LTAU)

*	Parameters/constants

	INTEGER DEPTH
	PARAMETER (DEPTH=2)

*       Local variables that need not be saved

*       Note that PATH is only used for debugging purposes, and can be
*       removed.

	REAL SBAR, MINSC, MAXSC, ALPHA
	INTEGER PBAR, I, J, IPTR, PATH(DEPTH)


*       Local state

*       It would be a bit more "general" to define S(LTAU), if Fortran
*       allows the argument of a function to be used as the dimension of
*       a local array variable.

*       IPOINT is always in the range 0 to DEPTH-1.

*       WARNING!
*       
*       In the original version of this subroutine, IPOINT, ALPHAX,
*       every element of S, and potentially any element of P with the
*       second index value .NE. IPTR were read without being given
*       initial values (all indices of P with second index equal to
*       IPTR are all written before being read in this subroutine).
*       
*       From examining the code carefully, it appears that all of these
*       should be saved from one invocation to the next.
*       
*       I've run lpcsim with the "-l 6" option to see all of the
*       debugging information that is printed out by this subroutine
*       below, and it appears that S, P, IPOINT, and ALPHAX are all
*       initialized to 0 (these initial values would likely be different
*       on different platforms, compilers, etc.).  Given that the output
*       of the coder sounds reasonable, I'm going to initialize these
*       variables to 0 explicitly.

	REAL S(60)
	INTEGER P(60,DEPTH), IPOINT
	REAL ALPHAX

	SAVE S, P, IPOINT
	SAVE ALPHAX

	DATA S/60*0./
	DATA P/120*0/, IPOINT/0/
	DATA ALPHAX/0./

*   Calculate the confidence factor ALPHA, used as a threshold slope in
*   SEESAW.  If unvoiced, set high slope so that every point in P array
*   is marked as a potential pitch frequency.  A scaled up version (ALPHAX)
*   is used to maintain arithmetic precision.

	IF( VOICE .EQ. 1 ) THEN
	   ALPHAX = .75*ALPHAX + AMDF(MINPTR)/2.
	ELSE
	   ALPHAX = (63./64.)*ALPHAX
	END IF
	ALPHA = ALPHAX/16
	IF( VOICE .EQ. 0 .AND. ALPHAX .LT. 128 ) ALPHA = 8

*  SEESAW: Construct a pitch pointer array and intermediate winner function
*   Left to right pass:

	IPTR = IPOINT+1
	P(1,IPTR) = 1
	I = 1
	PBAR = 1
	SBAR = S(1)
	DO I = 1,LTAU 
	   SBAR = SBAR + ALPHA
	   IF (SBAR .LT. S(I)) THEN
	      S(I) = SBAR
	      P(I,IPTR) = PBAR
	   ELSE
	      SBAR = S(I)
	      P(I,IPTR) = I
	      PBAR = I
	   END IF
	END DO

*   Right to left pass:

	I = PBAR-1
	SBAR = S(I+1)
	DO WHILE (I .GE. 1)
	   SBAR = SBAR + ALPHA
	   IF (SBAR .LT. S(I)) THEN
	      S(I) = SBAR
	      P(I,IPTR) = PBAR
	   ELSE
	      PBAR = P(I,IPTR)
	      I = PBAR
	      SBAR = S(I)
	   END IF
	   I = I-1
	END DO

*   Update S using AMDF
*   Find maximum, minimum, and location of minimum

	S(1) = S(1) + AMDF(1)/2
	MINSC = S(1)
	MAXSC = MINSC
	MIDX = 1
	DO I = 2,LTAU
	   S(I) = S(I) + AMDF(I)/2
	   IF (S(I) .GT. MAXSC) MAXSC = S(I)
	   IF (S(I) .LT. MINSC) THEN
	      MIDX = I
	      MINSC = S(I)
	   END IF
	END DO

*   Subtract MINSC from S to prevent overflow

	DO I = 1,LTAU
	   S(I) = S(I) - MINSC
	END DO
	MAXSC = MAXSC - MINSC

*   Use higher octave pitch if significant null there

	J = 0
	DO I = 20, 40, 10
	   IF (MIDX .GT. I) THEN
	      IF (S(MIDX-I) .LT. MAXSC/4) J = I
	   END IF
	END DO
	MIDX = MIDX - J

*   TRACE: look back two frames to find minimum cost pitch estimate

	J = IPOINT
	PITCH = MIDX
	DO I = 1,DEPTH
	   J = MOD(J,DEPTH) + 1
	   PITCH = P(PITCH,J)
	   PATH(I) = PITCH
	END DO
*       
*       The following statement subtracts one from IPOINT, mod DEPTH.  I
*       think the author chose to add DEPTH-1, instead of subtracting 1,
*       because then it will work even if MOD doesn't work as desired on
*       negative arguments.
*       
	IPOINT = MOD(IPOINT+DEPTH-1,DEPTH)

*   Print test data

*	IF (LISTL .GE. 3) THEN
*	   IF (LISTL .GE. 6) THEN
*	      WRITE(FDEBUG,970) 'DYPTRACK array (P):',P
*	      WRITE(FDEBUG,980) 'Pitch Winner Function (S):',S
*	   END IF
*	   WRITE(FDEBUG,950) IPOINT, MIDX, ALPHA, PITCH, PATH
*950	   FORMAT(' Pitch: IPOINT  MIDX  ALPHA   PITCH     PATH'/
*     1             5X,2I7,F7.0,I7,5X,10I4/)
*970	   FORMAT(1X,A,100(/1X,20I6))
*980	   FORMAT(1X,A,100(/1X,10F12.1))
*	END IF

	RETURN


	ENTRY INITDYPTRK ()

	DO I = 1,60
	   S(I) = 0.
	   DO J = 1,DEPTH
	      P(I,J) = 0
	   END DO
	END DO
	IPOINT = 0
	ALPHAX = 0.

	RETURN

	END
