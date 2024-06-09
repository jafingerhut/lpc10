/*
  
  Sun Nov  5 07:36:06 CST 1995     Andy Fingerhut (jaf@arl.wustl.edu)
  
  It appears that the Linux sound driver records 16 bit samples in
  signed format (at least, that is what the command srec stores when I
  asked it to record a sound with 16 bit samples).

  It appears that the LPC code that I have expects samples to be in 16
  bit unsigned format.  (Actually, I found out several minutes after
  writing this that they actually swap bytes in their files, compared
  to what Linux uses).

  This program converts between the two formats (in either direction)
  simply by reading in 16 bit words, flipping the most significant
  bit, and writing them out.  It couldn't get any simpler than that.

*/

#include <stdio.h>

typedef short INT16;


main(int argc, char **argv)
{
  INT16 one_sample;
  int ret;

  if (sizeof(INT16) != 2) {
    fprintf(stderr, "%s: Must recompile the program with a definition of INT16\n\
that makes its size equal to 16 bits.  It is currently equal to %d 'bytes'.\n",
	    argv[0], sizeof(INT16));
    exit(1);
  }

  while (fread(&one_sample, sizeof(one_sample), 1, stdin) == 1) {
    one_sample ^= 0x8000;
    if ((ret = fwrite(&one_sample, sizeof(one_sample), 1, stdout)) != 1) {
      fprintf(stderr, "%s: fwrite() to stdout failed with return value %d.\n",
	      argv[0], ret);
      exit(1);
    }
  }
}
