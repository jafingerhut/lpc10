	PROGRAM LOCTST

	integer i

C	open(unit=1, file='localtest.out', status='unknown')

	do i = 1, 5
	   call try()
	end do
	
	END


	subroutine try()

	integer i
	integer k

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C       Version 1
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

C       integer j/0/

C       Sun's f77 SPARCcompiler accepts the "integer j/0/" declaration,
C       and seems to treat it equivalently to the following three lines.
C       I don't know if this is "standard" or not.
C
C       integer j
C       data j/0/
C       save j

C       Both versions of f2c that I have tried (one from 1992, and the
C       most recent one obtained today, Feb 8 1996, from
C       ftp://netlib.att.com/netlib/f2c, give an error message like the
C       following:
C
C       localtest.f:
C          MAIN loctst:
C          try:
C       Error on line 16 of localtest.f: attempt to give DATA in type-declaration

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C       Version 2
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

C	integer j
C	data j/0/

C       All of Sun's f77 SPARCcompiler and both versions of f2c tried
C       accept this, and seem to treat it as if there were also a "save
C       j" statement.  The one freely available Fortran 77 standards
C       document I found says something that confuses me, but which
C       seems to imply that if the "save j" is not given explicitly,
C       then the value of j should not be saved from one invocation of
C       try() to the next, because it is modified (the "j = j + 1"
C       statement below) inside the subroutine.
C       
C       By the way, the freely available Fortran 77 standard document
C       was obtained from the URL:
C       ftp://ftp.ast.cam.ac.uk/pub/michael/f77.txt.gz
C       
C       It says, in section 8.9, "SAVE statement"
C----------------------------------------------------------------------
C         The execution of a RETURN statement or an END statement
C         within  a  subprogram  causes  all  entities within the
C         subprogram  to  become   undefined   except   for   the
C         following:
C
C            (1) Entities specified by SAVE statements
C
C            (2) Entities in blank common
C
C            (3) Initially defined  entities  that  have  neither
C                been redefined nor become undefined
C
C            (4) Entities in a named common block that appears in
C                the subprogram and appears in at least one other
C                program  unit  that   is   referencing,   either
C                directly or indirectly, that subprogram
C----------------------------------------------------------------------
C       
C       j obviously does not fall under category (1), (2), or (4).  I
C       believe that j is an "initially defined entity" as referred to
C       in (3), but I think that an assignment counts as j being
C       "redefined".
C       
C       Oh, well.  Maybe I'll just stick in an explicit SAVE statement,
C       make sure that doesn't change the behavior of the program for
C       any of the Fortran compilers I have available, and put in
C       explicit SAVE statements in the Fortran code I have, to document
C       it a bit better (for me, anyway).

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C       Version 3
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

	integer j
	data j/0/
	save j

C       All of Sun's f77 SPARCcompiler and both versions of f2c tried
C       accept this, and treat it as I would expect.
C       
C       f2c converts local variables to C static local variables in C
C       functions, and so their values are always retained from one
C       invocation to the next, even without an explicit save statement.
C       
C       Sun's f77 SPARCcompiler also appears to treat all local
C       variables, like k in this example, as if a "save k" statement
C       were in the program.  Maybe this is "standard", or maybe this is
C       just a feature of these two particular Fortran 77 compilers.

C       Another thing I added in this version was a separate variable k
C       that is not saved, and is also not initialized (neither with a
C       /value/ after its definition, nor with a DATA statement).

C       The code below prints out k and then assigns it a value, on each
C       of the first four calls to this subroutine.

C       The results of running this through Sun's f77 Fortran
C       SPARCcompiler, and f2c, both give the result that k's value is
C       preserved from one value to the next.  Again, this could be a
C       non-standard feature of these two compilers, and I wouldn't want
C       to write Fortran code that relied on this feature, unless this
C       feature is also standard.

C       The main reason for trying out this stuff with the new variable
C       k is to see whether giving an initial value to a local variable
C       changed whether its value was preserved from one call to the
C       next.  For what I tried, it doesn't make a difference.

	do i = 1, 10
	   j = j + 1
	end do

	if (j .eq. 10) then
	   write(6,910) k
	   k = 1
	else if (j .eq. 20) then
	   write(6,910) k
	   k = 2
	else if (j .eq. 30) then
	   write(6,910) k
	   k = 3
	else if (j .eq. 40) then
	   write(6,910) k
	   k = 4
	end if

	write(6,900) j
 900	format('local variable j is ', i3)
 910	format('local variable k is ', i3)

	return
	end
