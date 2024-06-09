FFLAGS= -fast -u -g
#FFLAGS=-C -u -g

OBJECTS= lpcsim.o setup.o frame.o prepro.o hp100.o \
analys.o preemp.o onset.o placev.o placea.o lpfilt.o ivfilt.o \
tbdm.o difmag.o voicin.o vparms.o dyptrk.o \
dcbias.o energy.o mload.o invert.o rcchk.o \
trans.o encode.o chanwr.o decode.o ham84.o median.o \
synths.o pitsyn.o irc2pc.o bsynz.o deemp.o random.o \
sread.o bitio.o error.o getcl.o vqsetup.o spdio.o

lpcsim: $(OBJECTS)
	$(LINK.f) -o $@ $(OBJECTS)

clean:
	rm -f lpcsim $(OBJECTS) core
