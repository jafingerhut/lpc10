******************************************************************
* 
* $Log: lpcdec.f,v $
* Revision 1.1  1996/03/28  00:03:00  jaf
* Initial revision
*
* 
******************************************************************
* 
* Decode 54 bits to one frame of 180 speech samples.
* 
* Input:
*  BITS   - 54 encoded bits, stored 1 per array element.
*           Indices 1 through 53 read (SYNC bit ignored).
* Output:
*  SPEECH - Speech encoded as real values in the range [-1,+1].
*           Indices 1 through 180 written.
* 
* This subroutine maintains local state from one call to the next.  If
* you want to switch to using a new audio stream for this filter, or
* reinitialize its state for any other reason, call the ENTRY
* INITLPCDEC.
*
	SUBROUTINE LPCDEC(BITS, SPEECH)
	INCLUDE 'config.fh'
	INCLUDE 'contrl.fh'

*       Arguments

	INTEGER BITS(54)
	REAL SPEECH(MAXFRM)

*       Local variables that need not be saved

*       Uncoded speech parameters

	INTEGER VOICE(2), PITCH
	REAL RMS, RC(MAXORD)

*       Coded speech parameters

	INTEGER IPITV, IRMS, IRC(MAXORD)

*       Others

	INTEGER LEN

*       Local state

*       None

	CALL CHANRD(MAXORD, IPITV, IRMS, IRC, BITS)
	CALL DECODE(IPITV, IRMS, IRC, VOICE, PITCH, RMS, RC)
	CALL SYNTHS(VOICE, PITCH, RMS, RC, SPEECH, LEN)

	RETURN



	ENTRY INITLPCDEC ()

*       Call initialization entries for any subroutines above that have
*       them.

	CALL INITDECODE ()
	CALL INITSYNTHS ()

	RETURN

	END
