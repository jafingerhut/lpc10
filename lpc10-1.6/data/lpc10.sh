#! /bin/sh

if [ $# -ne 2 ]
then
    1>&2 echo "usage: `basename $0` input-file output-file"
    1>&2 echo ""
    1>&2 echo "    Input and output files should be different, and their formats"
    1>&2 echo "    should be given by their file names, e.g. .wav or .aiff"
    1>&2 echo "    For a list of supported formats, run 'sox -h'."
    exit 1
fi

INFILE="$1"
OUTFILE="$2"

# The options used for sox commands:

# The first one takes the input file (name given in arg $INFILE) and
# converts it to the format expected by the LPC-10 compression
# program, which is raw mono audio sampled at 8 KHz with 16-bit signed
# linear samples.

# -t raw: raw input file format
# -r 8000: sample rate is 8000 Hertz
# -e signed-integer: sample format is signed integer
# -b 16: sample size is 16 bits
# --endian: specify big or little endian byte order
# -c 1: 1 sound channel, i.e. mono

# The following works on macOS and any Linux with Python3 installed.
ND=`python3 -c 'import sys; print(sys.byteorder);'`

SPD_SOX_OPTS="-t raw -r 8000 -e signed-integer -b 16 -c 1 --endian ${ND}"

# nuke compresses the audio using the LPC-10 codec, to a binary output
# file format.

# unnuke uncompresses it.

# The last sox command converts the output of unnuke to the desired
# output file (name given in arg $OUTFILE).

sox "${INFILE}" $SPD_SOX_OPTS - | nuke | unnuke | sox $SPD_SOX_OPTS - "${OUTFILE}"
