# 
# $Log: Makefile,v $
# Revision 1.1  1996/02/13  22:50:30  jaf
# Initial revision
#
# 


# 
# If you are using GNU make and C compiler (with executable name gcc),
# then hopefully the only thing you'll need to change below is the
# definition of F2C_BASE.  Its value should be the name of a directory
# that contains subdirectories include and lib, where include contains
# f2c.h, and lib contains libf2c.a.
# 

F2C_BASE=$(HOME)



include f2c-rules

CFLAGS=-I$(F2C_BASE)/include
F2CFLAGS=-u -A -c -72 -kr -P
# 
# This option could cause the code to break unless all local variables
# that need to be saved from one invocation to the next (i.e.,
# declared static in C functions), have either SAVE or DATA statements
# in the Fortran source.
# 
F2CFLAGS+=-a
# 
# I'm just going to add this option to turn on array index bounds
# checking for when I want to check for problems.
# 
#F2CFLAGS+=-C
# 
# The -ec option places uninitialized COMMON blocks (like common block
# CONTRL in contrl.fh of the LPC-10 code) in separate files.  When
# this option is not used, f2c takes all of the several files that
# include contrl.fh and declare a "struct { ... } contrl_;" at their
# beginning of their C version, containing the members of that common
# block.  It looks to me like a C compiler should make all of these
# struct's different from each other, and not share common memory.  I
# don't understand how any of this code could have worked without this
# option, although it seemed to work fine.  I'll have to think about
# this more some time.  Perhaps my interpretation of the resulting C
# code without this option is mistaken.
# 
# When using this option, one must add contrl_com.o to the list of .o
# files to link together, as f2c creates a file contrl_com.c whenever
# it compiles a .f file that includes contrl.fh.  See also the rule
# for contrl_com.c below, and the comments before it.
# 
F2CFLAGS+=-ec
F2CLIBS=-L$(F2C_BASE)/lib -lf2c -lm

# 
# For my home Linux machine using the GCC compiler, joshua.wustl.edu
# 

#CC=gcc
#CFLAGS+=-Wall
#CFLAGS+=-ggdb -Wall
# ^^^^^^^^^^^^^^^^^^
# 
# I'd like to use -ggdb at home, but when doing the final linking of
# all the .o files, it gives an error message something like "the
# library -lg doesn't exist".  I would guess that I need -ggdb
# compiled versions of the GNU C library for using that option when
# linking.  Can I still debug most of the program if all the .f/.c
# files are compiled with -ggdb, but the linking is done without?

# 
# For the Solaris 5.3 Sparc machine siesta.wustl.edu
# 

CC=gcc
CFLAGS+=-Wall
#CFLAGS+=-ggdb
CFLAGS+=-O
CFLAGS+=-I/usr/ucbinclude
# For profiling
CFLAGS+=-pg
OTHER_LIBS=-L/usr/ucblib -lucb

# 
# For the SunOS 4.1.4 Sparc machine leia.wustl.edu.
# 

#CC=gcc
#CFLAGS+=-ggdb -Wall


OBJECTS= \
	lpcsim.o setup.o frame.o prepro.o hp100.o \
	analys.o preemp.o onset.o placev.o placea.o lpfilt.o ivfilt.o \
	tbdm.o difmag.o voicin.o vparms.o dyptrk.o \
	dcbias.o energy.o mload.o invert.o rcchk.o \
	trans.o encode.o chanwr.o decode.o ham84.o median.o \
	synths.o pitsyn.o irc2pc.o bsynz.o deemp.o random.o \
	sread.o bitio.o error.o getcl.o vqsetup.o spdio.o \
	lnblnk.o extra.o \
	contrl_com.o

# 
# This list of files automatically created by f2c is here just so that
# the rule for the target "clean" below can remove them.  The rule for
# clean should _not_ remove all files matching the pattern *.c,
# because then the original source file spdio.c would also be removed.
# 

F2C_INTERMEDIATES = \
	analys.c \
	bitio.c \
	bsynz.c \
	chanwr.c \
	contrl_com.c \
	dcbias.c \
	decode.c \
	deemp.c \
	difmag.c \
	dyptrk.c \
	encode.c \
	energy.c \
	error.c \
	frame.c \
	getcl.c \
	ham84.c \
	hp100.c \
	invert.c \
	irc2pc.c \
	ivfilt.c \
	lnblnk.c \
	lpcsim.c \
	lpfilt.c \
	median.c \
	mload.c \
	onset.c \
	pitsyn.c \
	placea.c \
	placev.c \
	preemp.c \
	prepro.c \
	random.c \
	rcchk.c \
	setup.c \
	sread.c \
	synths.c \
	tbdm.c \
	trans.c \
	voicin.c \
	vparms.c \
	vqsetup.c


lpcsim: $(OBJECTS)
	$(LINK.c) -o $@ $(OBJECTS) $(F2CLIBS) $(OTHER_LIBS)

clean:
	rm -f *.o lpcsim $(F2C_INTERMEDIATES)


# 
# contrl_com.c is created whenever any .f source file that includes
# contrl.fh is run through f2c with the '-ec' option.  However,
# without a rule like the one below, make doesn't "notice" that
# contrl_com.c is created in the middle of a run, and complains that
# it doesn't know how to create contrl_com.o.
# 
# I've just arbitrarily selected analys.f as a file that includes
# contrl.fh, and given a command that will create contrl_com.c but
# nothing else.
# 

contrl_com.c: contrl.fh
	$(F2C) $(F2CFLAGS) $(F2CFLAGS_CMDLINE) < analys.f > /dev/null

analys.f:	config.fh
analys.f:	contrl.fh
bsynz.f:	config.fh
bsynz.f:	contrl.fh
decode.f:	config.fh
decode.f:	contrl.fh
dyptrk.f:	contrl.fh
encode.f:	config.fh
encode.f:	contrl.fh
error.f:	contrl.fh
frame.f:	contrl.fh
getcl.f:	getcl_defs.fh
getcl.f:	getcl_defs.fh
getcl.f:	getcl_defs.fh
getcl.f:	getcl_defs.fh
getcl.f:	getcl_defs.fh
invert.f:	config.fh
irc2pc.f:	config.fh
lpcdec.f:	config.fh
lpcdec.f:	contrl.fh
lpcenc.f:	config.fh
lpcini.f:	config.fh
lpcini.f:	contrl.fh
lpcsim.f:	config.fh
lpcsim.f:	contrl.fh
nuke.f:		config.fh
nuke.f:		contrl.fh
onset.f:	config.fh
pitsyn.f:	config.fh
setup.f:	config.fh
setup.f:	contrl.fh
synths.f:	config.fh
synths.f:	contrl.fh
trans.f:	config.fh
trans.f:	contrl.fh
unnuke.f:	config.fh
unnuke.f:	contrl.fh
voicin.f:	contrl.fh
vqsetup.f:	config.fh
vqsetup.f:	contrl.fh
vqsetup.f:	contrl.fh
