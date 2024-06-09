/*
 * $Log: spdio.c,v $
 * Revision 1.2  1996/02/12  15:16:42  jaf
 * Changed several things explained at length in comments.
 *
 * Revision 1.1  1996/02/07 14:49:35  jaf
 * Initial revision
 *
 */


#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
/* Added <unistd.h> because in the GNU C library, it contains the
   prototype for the read, write, and close system calls.  We might
   want to wrap an #ifdef around this, to prevent it from being used
   when the GNU C library doesn't exist. */
#include <unistd.h>
#include "f2c.h"

/*
  Sun Feb 11 13:07:25 CST 1996
  Andy Fingerhut (jaf@arl.wustl.edu)

  I'm changing the types of the arguments to match those given in the
  f2c output of setup.f, as shown here:

    extern integer spd_open__(char *, integer *, ftnlen);
    extern / * Subroutine * / int itime_(integer *), getcl_bit__(char *, 
	    integer *, integer *, ftnlen), flush_(integer *), spd_close__(
	    integer *);

  I'm also changing the types of the arguments of spd_read_ and
  spd_write_ to match the declarations that get produced when
  converting sread.f to C with "f2c -u -A -c -72 -kr -P".

    extern integer spd_read__(integer *, shortint *, integer *);
    extern integer spd_write__(integer *, shortint *, integer *);

  Changed the style to ANSI C style declarations.

  Changed the names of the functions to have two underscores after
  them instead of 1, as shown above.

  
 */

void Perr(char *s);


integer
spd_open__(f_ptr, flags, f_len)
char *f_ptr;
integer *flags;
ftnlen f_len;
{
	char *s, *z;
	int i, flag=*flags;

	s = z = (char *)malloc(f_len + 1);
	for (i=0; i<f_len; i++) *z++ = *f_ptr++;
	*z++ = 0;
	if (z=strchr(s, ' ')) *z = 0;
	if (flag && O_WRONLY) flag |= O_CREAT;
	if ((i = open(s, flag, 0666)) < 0) {
	    fprintf(stderr, "%s:", s);
	    Perr("open"); }
	free(s);
	return(i);
}


integer
spd_close__(fd)
integer *fd;
{
  /* Originally, this line called close(fd) rather than close(*fd).
     That was an error in the original. */
	return(close(*fd));
}


integer
spd_read__(fd, buf, n)
integer *fd, *n;
shortint *buf;
{
	int i;
	if((i = read(*fd, buf, *n)) < 0)
	    Perr("read");
	return(i);
}


integer
spd_write__(fd, buf, n)
integer *fd, *n;
shortint *buf;
{
	int i;
	if ((i = write(*fd, buf, *n)) < 0)
	    Perr("write");
	return(i);
}


void
Perr(s)
char *s;
{
	perror(s);
	exit(-1);
}
