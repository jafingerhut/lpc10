/* localtest.f -- translated by f2c (version 19951025).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Table of constant values */

static integer c__1 = 1;

/* Main program */ MAIN__(void)
{
    static integer i__;
    extern /* Subroutine */ int try_(void);

/* 	open(unit=1, file='localtest.out', status='unknown') */
    for (i__ = 1; i__ <= 5; ++i__) {
	try_();
    }
    return 0;
} /* MAIN__ */

/* Subroutine */ int try_(void)
{
    /* Initialized data */

    static integer j = 0;

    /* Format strings */
    static char fmt_910[] = "(\002local variable k is \002,i3)";
    static char fmt_900[] = "(\002local variable j is \002,i3)";

    /* Builtin functions */
    integer s_wsfe(cilist *), do_fio(integer *, char *, ftnlen), e_wsfe(void);

    /* Local variables */
    static integer i__, k;

    /* Fortran I/O blocks */
    static cilist io___4 = { 0, 6, 0, fmt_910, 0 };
    static cilist io___6 = { 0, 6, 0, fmt_910, 0 };
    static cilist io___7 = { 0, 6, 0, fmt_910, 0 };
    static cilist io___8 = { 0, 6, 0, fmt_910, 0 };
    static cilist io___9 = { 0, 6, 0, fmt_900, 0 };


/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 
*/
/*       Version 1 */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 
*/
/*       integer j/0/ */
/*       Sun's f77 SPARCcompiler accepts the "integer j/0/" declaration, 
*/
/*       and seems to treat it equivalently to the following three lines. 
*/
/*       I don't know if this is "standard" or not. */

/*       integer j */
/*       data j/0/ */
/*       save j */
/*       Both versions of f2c that I have tried (one from 1992, and the */
/*       most recent one obtained today, Feb 8 1996, from */
/*       ftp://netlib.att.com/netlib/f2c, give an error message like the 
*/
/*       following: */

/*       localtest.f: */
/*          MAIN loctst: */
/*          try: */
/*      Error on line 16 of localtest.f: attempt to give DATA in type-decl
aration*/
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 
*/
/*       Version 2 */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 
*/
/* 	integer j */
/* 	data j/0/ */
/*       All of Sun's f77 SPARCcompiler and both versions of f2c tried */
/*       accept this, and seem to treat it as if there were also a "save 
*/
/*       j" statement.  The one freely available Fortran 77 standards */
/*       document I found says something that confuses me, but which */
/*       seems to imply that if the "save j" is not given explicitly, */
/*       then the value of j should not be saved from one invocation of */
/*       try() to the next, because it is modified (the "j = j + 1" */
/*       statement below) inside the subroutine. */

/*       By the way, the freely available Fortran 77 standard document */
/*       was obtained from the URL: */
/*       ftp://ftp.ast.cam.ac.uk/pub/michael/f77.txt.gz */

/*       It says, in section 8.9, "SAVE statement" */
/* ---------------------------------------------------------------------- 
*/
/*         The execution of a RETURN statement or an END statement */
/*         within  a  subprogram  causes  all  entities within the */
/*         subprogram  to  become   undefined   except   for   the */
/*         following: */

/*            (1) Entities specified by SAVE statements */

/*            (2) Entities in blank common */

/*            (3) Initially defined  entities  that  have  neither */
/*                been redefined nor become undefined */

/*            (4) Entities in a named common block that appears in */
/*                the subprogram and appears in at least one other */
/*                program  unit  that   is   referencing,   either */
/*                directly or indirectly, that subprogram */
/* ---------------------------------------------------------------------- 
*/

/*       j obviously does not fall under category (1), (2), or (4).  I */
/*       believe that j is an "initially defined entity" as referred to */
/*       in (3), but I think that an assignment counts as j being */
/*       "redefined". */

/*       Oh, well.  Maybe I'll just stick in an explicit SAVE statement, 
*/
/*       make sure that doesn't change the behavior of the program for */
/*       any of the Fortran compilers I have available, and put in */
/*       explicit SAVE statements in the Fortran code I have, to document 
*/
/*       it a bit better (for me, anyway). */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 
*/
/*       Version 3 */
/* CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 
*/
/*       All of Sun's f77 SPARCcompiler and both versions of f2c tried */
/*       accept this, and treat it as I would expect. */

/*       f2c converts local variables to C static local variables in C */
/*       functions, and so their values are always retained from one */
/*       invocation to the next, even without an explicit save statement. 
*/

/*       Sun's f77 SPARCcompiler also appears to treat all local */
/*       variables, like k in this example, as if a "save k" statement */
/*       were in the program.  Maybe this is "standard", or maybe this is 
*/
/*       just a feature of these two particular Fortran 77 compilers. */
/*       Another thing I added in this version was a separate variable k 
*/
/*       that is not saved, and is also not initialized (neither with a */
/*       /value/ after its definition, nor with a DATA statement). */
/*       The code below prints out k and then assigns it a value, on each 
*/
/*       of the first four calls to this subroutine. */
/*       The results of running this through Sun's f77 Fortran */
/*       SPARCcompiler, and f2c, both give the result that k's value is */
/*       preserved from one value to the next.  Again, this could be a */
/*       non-standard feature of these two compilers, and I wouldn't want 
*/
/*       to write Fortran code that relied on this feature, unless this */
/*       feature is also standard. */
/*       The main reason for trying out this stuff with the new variable 
*/
/*       k is to see whether giving an initial value to a local variable 
*/
/*       changed whether its value was preserved from one call to the */
/*       next.  For what I tried, it doesn't make a difference. */
    for (i__ = 1; i__ <= 10; ++i__) {
	++j;
    }
    if (j == 10) {
	s_wsfe(&io___4);
	do_fio(&c__1, (char *)&k, (ftnlen)sizeof(integer));
	e_wsfe();
	k = 1;
    } else if (j == 20) {
	s_wsfe(&io___6);
	do_fio(&c__1, (char *)&k, (ftnlen)sizeof(integer));
	e_wsfe();
	k = 2;
    } else if (j == 30) {
	s_wsfe(&io___7);
	do_fio(&c__1, (char *)&k, (ftnlen)sizeof(integer));
	e_wsfe();
	k = 3;
    } else if (j == 40) {
	s_wsfe(&io___8);
	do_fio(&c__1, (char *)&k, (ftnlen)sizeof(integer));
	e_wsfe();
	k = 4;
    }
    s_wsfe(&io___9);
    do_fio(&c__1, (char *)&j, (ftnlen)sizeof(integer));
    e_wsfe();
    return 0;
} /* try_ */

/* Main program alias */ int loctst_ () { MAIN__ (); return 0; }
