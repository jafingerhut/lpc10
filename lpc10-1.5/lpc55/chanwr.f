************************************************************************
*
*	CHANL Version 49
*
* $Log: chanwr.f,v $
* Revision 1.3  1996/03/21  15:14:57  jaf
* Added comments about which indices of argument arrays are read or
* written, and about the one bit of local state in CHANWR.  CHANRD
* has no local state.
*
* Revision 1.2  1996/03/13  18:55:10  jaf
* Comments added explaining which of the local variables of this
* subroutine need to be saved from one invocation to the next, and which
* do not.
*
* Revision 1.1  1996/02/07 14:43:31  jaf
* Initial revision
*
*
************************************************************************
*
* CHANWR:
*   Place quantized parameters into bitstream
*
* Input:
*  ORDER  - Number of reflection coefficients (not really variable)
*  IPITV  - Quantized pitch/voicing parameter
*  IRMS   - Quantized energy parameter
*  IRC    - Quantized reflection coefficients
*           Indices 1 through ORDER read.
* Output:
*  IBITS  - Serial bitstream
*           Indices 1 through 54 written.
*           Bit 54, the SYNC bit, alternates from one call to the next.
* 
* Subroutine CHANWR maintains one bit of local state from one call to
* the next, in the variable ISYNC.  I believe that this one bit is only
* intended to allow a receiver to resynchronize its interpretation of
* the bit stream, by looking for which of the 54 bits alternates every
* frame time.  This is just a simple framing mechanism that is not
* useful when other, higher overhead framing mechanisms are used to
* transmit the coded frames.
* 
* I'm not going to make an entry to reinitialize this bit, since it
* doesn't help a receiver much to know whether the first sync bit is a 0
* or a 1.  It needs to examine several frames in sequence to have
* reasonably good assurance that its framing is correct.
*
*
* CHANRD:
*   Reconstruct parameters from bitstream
*
* Input:
*  ORDER  - Number of reflection coefficients (not really variable)
*  IBITS  - Serial bitstream
*           Indices 1 through 53 read (SYNC bit is ignored).
* Output:
*  IPITV  - Quantized pitch/voicing parameter
*  IRMS   - Quantized energy parameter
*  IRC    - Quantized reflection coefficients
*           Indices 1 through ORDER written
*
* Entry CHANRD has no local state.
*
*
*
*   IBITS is 54 bits of LPC data ordered as follows:
*	R1-0, R2-0, R3-0,  P-0,  A-0,
*	R1-1, R2-1, R3-1,  P-1,  A-1,
*	R1-2, R4-0, R3-2,  A-2,  P-2, R4-1,
*	R1-3, R2-2, R3-3, R4-2,  A-3,
*	R1-4, R2-3, R3-4, R4-3,  A-4,
*	 P-3, R2-4, R7-0, R8-0,  P-4, R4-4,
*	R5-0, R6-0, R7-1,R10-0, R8-1,
*	R5-1, R6-1, R7-2, R9-0,  P-5,
*	R5-2, R6-2,R10-1, R8-2,  P-6, R9-1,
*	R5-3, R6-3, R7-3, R9-2, R8-3, SYNC

	SUBROUTINE CHANWR( ORDER, IPITV, IRMS, IRC, IBITS )

*       Arguments

	INTEGER ORDER, IPITV, IRMS, IRC(ORDER), IBITS(54)

*       Parameters/constants

*       These arrays are not Fortran PARAMETER's, but they are defined
*       by DATA statements below, and their contents are never altered.

	INTEGER IBLIST(53), BIT(10)

*       Local variables that need not be saved

	INTEGER I
	INTEGER ITAB(13)

*       Local state

*       ISYNC is only used by CHANWR, not by ENTRY CHANRD.

	INTEGER ISYNC

	SAVE ISYNC

	DATA ISYNC/0/

	DATA BIT/ 2, 4, 8, 8, 8, 8, 16, 16, 16, 16 /
	DATA IBLIST/13, 12, 11, 1, 2, 13, 12, 11, 1, 2, 13, 10,
     1             11, 2, 1, 10, 13, 12, 11, 10, 2, 13, 12, 11,
     1             10, 2, 1, 12, 7, 6, 1, 10, 9, 8, 7, 4,
     1              6, 9, 8, 7, 5, 1, 9, 8, 4, 6, 1, 5,
     1              9, 8, 7, 5, 6 /

************************************************************************
*	Place quantized parameters into bitstream
************************************************************************

*   Place parameters into ITAB

	ITAB(1) = IPITV
	ITAB(2) = IRMS
	ITAB(3) = 0
	DO I = 1,ORDER
	   ITAB(I+3) = AND( IRC(ORDER+1-I), 32767 )
	END DO

*   Put 54 bits into IBITS array

	DO I = 1,53
	   IBITS(I) = AND(ITAB(IBLIST(I)),1)
	   ITAB(IBLIST(I)) = ITAB(IBLIST(I)) / 2
	END DO
	IBITS(54) = AND(ISYNC,1)
	ISYNC = 1 - ISYNC

	RETURN

************************************************************************
*	Reconstruct parameters from bitstream
************************************************************************

	ENTRY CHANRD( ORDER, IPITV, IRMS, IRC, IBITS )

*   Reconstruct ITAB

	DO I = 1,13
	   ITAB(I) = 0
	END DO
	DO I = 1,53
	   ITAB(IBLIST(54-I)) = ITAB(IBLIST(54-I))*2 + IBITS(54-I)
	END DO

*   Sign extend RC's

	DO I = 1,ORDER
	   IF( AND( ITAB(I+3), BIT(I) ) .NE. 0 )
     1    ITAB(I+3) = ITAB(I+3) - 2*BIT(I)
	END DO

*   Restore variables

	IPITV = ITAB(1)
	IRMS = ITAB(2)
	DO I = 1,ORDER
	   IRC(I) = ITAB(ORDER+4-I)
	END DO

	RETURN
	END
