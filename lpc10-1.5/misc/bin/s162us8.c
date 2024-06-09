#include <stdio.h>

#include "lpc10.h"

main()
{
    int sample_out;
    INT16 sample_in;

    while (fread(&sample_in, sizeof(INT16), 1, stdin) == 1) {
        sample_out = (sample_in >> 8) ^ 0x80;
        fputc(sample_out, stdout);
    }
}
