/*

This program should print either two normal v's, if \v is not
recognized as an escape sequence for the vertical tab (control-K), or
two control-K's, if it is.

On siesta.wustl.edu and ritz.cec.wustl.edu (both running Solaris 2.3
or 2.4), compiling with GCC 2.6.0, this program prints a v followed
by a control-K.  I don't know yet if this is a problem with GCC 2.6.0
in general, or only on this operating system, or only because of some
option that was set badly when it was compiled on these systems.

On leia.wustl.edu (running SunOS 4.1.4), compiling GCC 2.5.8, this
program prints two control-K's.

I tried out GCC 2.7.0 on my home Linux machine, and it worked correctly
(printing two control-K's).

*/

main()
{
    char str1[2];
    char str2[2];

    strcpy(str1, "\v");
    str2[0] = '\v';
    str2[1] = '\0';

    printf("%s", str1);
    printf("%s", str2);
}
