******************************************************************
*
*	HAM84 Version 45G
*
* $Log: ham84.f,v $
* Revision 1.3  1996/03/21  15:26:00  jaf
* Put comment header in standard form.
*
* Revision 1.2  1996/03/13  22:00:13  jaf
* Comments added explaining that none of the local variables of this
* subroutine need to be saved from one invocation to the next.
*
* Revision 1.1  1996/02/07 14:47:04  jaf
* Initial revision
*
*
******************************************************************
*
*  Hamming 8,4 Decoder - can correct 1 out of seven bits
*   and can detect up to two errors.
*
* Input:
*  INPUT  - Seven bit data word, 4 bits parameter and
*           4 bits parity information
* Input/Output:
*  ERRCNT - Sums errors detected by Hamming code
* Output:
*  OUTPUT - 4 corrected parameter bits
* 
* This subroutine is entered with an eight bit word in INPUT.  The 8th
* bit is parity and is stripped off.  The remaining 7 bits address the
* hamming 8,4 table and the output OUTPUT from the table gives the 4
* bits of corrected data.  If bit 4 is set, no error was detected.
* ERRCNT is the number of errors counted.
*
* This subroutine has no local state.
*
	SUBROUTINE HAM84( INPUT, OUTPUT, ERRCNT )

*       Arguments

	INTEGER INPUT, OUTPUT, ERRCNT

*       Parameters/constants

	INTEGER DACTAB(128)

*       Local variables that need not be saved

	INTEGER I, J, PARITY

	DATA DACTAB/O'20',0,0,3,0,5,O'16',7,0,O'11',O'16',O'13',
     1   O'16',O'15',O'36',O'16',0,O'11',2,7,4,7,7,O'27',O'11',
     1   O'31',O'12',O'11',O'14',O'11',O'16',7,0,5,2,O'13',5,O'25',
     1   6,5,O'10',O'13',O'13',O'33',O'14',5,O'16',O'13',2,1,O'22',
     1   2,O'14',5,2,7,O'14',O'11',2,O'13',O'34',O'14',O'14',O'17',
     1   0,3,3,O'23',4,O'15',6,3,O'10',O'15',O'12',3,O'15',O'35',
     1   O'16',O'15',4,1,O'12',3,O'24',4,4,7,O'12',O'11',O'32',
     1   O'12',4,O'15',O'12',O'17',O'10',1,6,3,6,5,O'26',6,O'30',
     1   O'10',O'10',O'13',O'10',O'15',6,O'17',1,O'21',2,1,4,1,6,
     1   O'17',O'10',1,O'12',O'17',O'14',O'17',O'17',O'37'/

*  Determine parity of input word

	PARITY = AND( INPUT, 255 )
	PARITY = XOR( PARITY, PARITY/16 )
	PARITY = XOR( PARITY, PARITY/4 )
	PARITY = XOR( PARITY, PARITY/2 )
	PARITY = AND( PARITY, 1 )

	I = DACTAB( AND(INPUT,127) + 1 )
	OUTPUT = AND(I,15)
	J = AND(I,16)
	IF(J.NE.0) THEN
*          No errors detected in seven bits
	   IF(PARITY.NE.0) ERRCNT = ERRCNT + 1
	ELSE
*          One or two errors detected
	   ERRCNT = ERRCNT + 1
	   IF(PARITY.EQ.0) THEN
*             Two errors detected
	      ERRCNT = ERRCNT + 1
	      OUTPUT = -1
	   END IF
	END IF

	RETURN
	END
