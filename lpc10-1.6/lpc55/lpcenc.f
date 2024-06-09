******************************************************************
* 
* $Log: lpcenc.f,v $
* Revision 1.2  1996/03/28  00:01:22  jaf
* Commented out some trace statements.
*
c Revision 1.1  1996/03/28  00:00:27  jaf
c Initial revision
c
* 
******************************************************************
* 
* Encode one frame of 180 speech samples to 54 bits.
* 
* Input:
*  SPEECH - Speech encoded as real values in the range [-1,+1].
*           Indices 1 through 180 read, and modified (by PREPRO).
* Output:
*  BITS   - 54 encoded bits, stored 1 per array element.
*           Indices 1 through 54 written.
* 
* This subroutine maintains local state from one call to the next.  If
* you want to switch to using a new audio stream for this filter, or
* reinitialize its state for any other reason, call the ENTRY
* INITLPCENC.
*
	SUBROUTINE LPCENC(SPEECH, BITS)
	INCLUDE 'config.fh'

*       Arguments

	REAL SPEECH(MAXFRM)
	INTEGER BITS(54)

*       Local variables that need not be saved

*       Uncoded speech parameters

	INTEGER VOICE(2), PITCH
	REAL RMS, RC(MAXORD)

*       Coded speech parameters

	INTEGER IPITV, IRMS, IRC(MAXORD)

*       Local state

*       None

	CALL PREPRO(SPEECH, MAXFRM)
	CALL ANALYS(SPEECH, VOICE, PITCH, RMS, RC)

*	WRITE (10,999) VOICE, PITCH, RMS, RC
* 999	FORMAT(1X,'ANALYS-> VOICE ',2I4,' PITCH ',I4,' RMS ',E10.4,
*     1         ' RC ',10E10.4)

	CALL ENCODE(VOICE, PITCH, RMS, RC, IPITV, IRMS, IRC)

*	WRITE (10,998) IPITV, IRMS, IRC
* 998	FORMAT(1X,'ENCODE-> IPITV ',I4,' RMS ',I8,
*     1         ' RC ',10I8)

	CALL CHANWR(MAXORD, IPITV, IRMS, IRC, BITS)

	RETURN



	ENTRY INITLPCENC ()

*       Call initialization entries for any subroutines above that have
*       them.

	CALL INITPREPRO ()
	CALL INITANALYS ()

	RETURN

	END
