#! /bin/bash

# The following works on many Linux systems, but not macOS
#ND=`lscpu | grep 'Byte Order' | awk '{print $3}'`

# The following works on macOS and any Linux with Python3 installed.
ND=`python3 -c 'import sys; print(sys.byteorder);'`

#echo "Found that processor has endianness: ${ND}"
ENDIANNESS=${ND} make test
