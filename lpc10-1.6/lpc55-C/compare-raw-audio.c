/*
 * Copyright 2024 John Andrew Fingerhut (andy.fingerhut@gmail.com)
 *
 * Released under the BSD 3-Clause "New" or "Revised" License
 *
 * https://spdx.org/licenses/BSD-3-Clause.html
 * SPDX Full name: BSD 3-Clause "New" or "Revised" License
 * SPDX Identifier: name BSD-3-Clause
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "lpc10.h"


int
read_16bit_words(FILE *f, INT16 speech[], int n)
{
    int samples_read;

    samples_read = fread(speech, sizeof(INT16), n, f);
    return (samples_read);
}


void print_usage(FILE *f, char *progname) {
    fprintf(f, "usage: %s <audio-file1> <audio-file2>\n",
            progname);
}


#define MIN_POSSIBLE_DELTA -65535

int
main(int argc, char *argv[])
{
    char *fname1, *fname2;
    FILE *infile1, *infile2;
    int n1, n2;
    INT16 speech1[LPC10_SAMPLES_PER_FRAME];
    INT16 speech2[LPC10_SAMPLES_PER_FRAME];
    int s1, s2, delta;
    int i;
    int num_samples_with_delta[2*65536];
    int min_delta, max_delta;
    long delta_sum;
    int num_samples_compared;

    if (argc != 3) {
        print_usage(stderr, argv[0]);
        exit(1);
    }
    fname1 = argv[1];
    infile1 = fopen(fname1, "r");
    if (infile1 == NULL) {
        fprintf(stderr, "Could not open file '%s' for reading,\n",
                fname1);
        exit(1);
    }
    fname2 = argv[2];
    infile2 = fopen(fname2, "r");
    if (infile2 == NULL) {
        fprintf(stderr, "Could not open file '%s' for reading,\n",
                fname2);
        exit(1);
    }

    for (delta = -65535; delta <= 65535; delta += 1) {
        num_samples_with_delta[delta - MIN_POSSIBLE_DELTA] = 0;
    }
    delta_sum = 0;
    min_delta = 65535;
    max_delta = -65535;
    num_samples_compared = 0;
    while (1) {
	n1 = read_16bit_words(infile1, speech1, LPC10_SAMPLES_PER_FRAME);
	n2 = read_16bit_words(infile2, speech2, LPC10_SAMPLES_PER_FRAME);
	if (n1 != LPC10_SAMPLES_PER_FRAME) {
	    break;
	}
	if (n2 != LPC10_SAMPLES_PER_FRAME) {
	    break;
	}
        num_samples_compared += LPC10_SAMPLES_PER_FRAME;
        for (i = 0; i < LPC10_SAMPLES_PER_FRAME; i++) {
            s1 = (int) speech1[i];
            s2 = (int) speech2[i];
            delta = s2 - s1;
            ++num_samples_with_delta[delta - MIN_POSSIBLE_DELTA];
            delta_sum += delta;
            if (delta < min_delta) {
                min_delta = delta;
            }
            if (delta > max_delta) {
                max_delta = delta;
            }
        }
    }
    if (n1 < n2) {
        printf("File '%s' is at least %u samples longer than file '%s'\n",
               fname2, n2 - n1, fname1);
    } else if (n1 > n2) {
        printf("File '%s' is at least %u samples longer than file '%s'\n",
               fname1, n1 - n2, fname2);
    }
    printf("Delta   Number of samples that differed by delta from file 1 to 2\n");
    printf("------  ----------------------------------------\n");
    for (delta = -65535; delta <= 65535; delta += 1) {
        if (num_samples_with_delta[delta - MIN_POSSIBLE_DELTA] != 0) {
            printf("%6d  %u\n", delta,
                   num_samples_with_delta[delta - MIN_POSSIBLE_DELTA]);
        }
    }
    printf("------  ----------------------------------------\n");
    printf("delta min=%d  max=%d  average=%.6f\n",
           min_delta, max_delta, ((double) delta_sum) / num_samples_compared);
    exit(0);
}
