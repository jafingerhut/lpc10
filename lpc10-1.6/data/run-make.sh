#! /bin/bash

ND=`lscpu | grep 'Byte Order' | awk '{print $3}'`
echo "Found that processor has endianness: ${ND}"
ENDIANNESS=${ND} make test
