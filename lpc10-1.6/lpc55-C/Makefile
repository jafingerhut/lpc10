# 
# Makefile for demo main programs using LPC-10 speech coder library
# 

WARNINGS = -Wall
CFLAGS = -O3 $(WARNINGS)

# default C compiler
CC= gcc

.PHONY: all clean

all: nuke unnuke nuke2 unnuke2 compare-raw-audio

nuke:	nuke.o bitio.o sampleio.o liblpc10.a
	$(CC) -o $@ nuke.o bitio.o sampleio.o -L. -llpc10 -lm

unnuke:	unnuke.o bitio.o sampleio.o liblpc10.a
	$(CC) -o $@ unnuke.o bitio.o sampleio.o -L. -llpc10 -lm

nuke2:	nuke2.o bitio.o sampleio.o liblpc10.a
	$(CC) -o $@ nuke2.o bitio.o sampleio.o -L. -llpc10 -lm

unnuke2:	unnuke2.o bitio.o sampleio.o liblpc10.a
	$(CC) -o $@ unnuke2.o bitio.o sampleio.o -L. -llpc10 -lm

compare-raw-audio: compare-raw-audio.o
	$(CC) -o $@ compare-raw-audio.o


clean:
	-rm -f *.o liblpc10.a nuke unnuke nuke2 unnuke2 compare-raw-audio
