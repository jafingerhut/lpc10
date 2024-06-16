# Introduction

This repository contains two implementations, one in Fortran, another
in C, for a [speech
codec](https://en.wikipedia.org/wiki/Category:Speech_codecs) called
LPC-10.  It can compress human speech audio to 2400 bits per second.
Note that speech codecs are specialized for compressing audio
containing human speech, and is not intended to be used for arbitrary
audio signals (e.g. music).

The code has no dependencies on other libraries.  The compressor takes
audio waveform data as input and produces compressed data as output,
and the decompressor does the opposite.

Based on the [FAQ](lpc10-1.5/FAQ) included with the original Fortran
code implementation, I believe it implements the FS-1015 standard,
which uses a Linear predictive coding technique

+ Linear predicative coding
  + https://en.wikipedia.org/wiki/Linear_predictive_coding
+ FS-1015 (aka FED-STD-1015), FIPS 137
  + https://en.wikipedia.org/wiki/FIPS_137

The original code (see below for more details) from which the code in
this repository was derived appears to have been published in October
1993 by the U.S. Department of Defense.


# Compiling the code

Tested on the following systems:

+ Ubuntu 20.04 x86_64 with GCC 9.4.0
+ Ubuntu 22.04 x86_64 with GCC 11.4.0
+ Ubuntu 24.04 x86_64 with GCC 13.2.0
+ Ubuntu 20.04 aarch64 with GCC 9.4.0
  + Only small differences between expected vs actual test output for
    these Ubuntu aarch64 processor tests, probably due to slightly
    different floating-point instruction round-offs.
+ Ubuntu 22.04 aarch64 with GCC 11.4.0
+ Ubuntu 24.04 aarch64 with GCC 13.2.0
+ macOS 12.7 x86_64 with clang 14.0.0
+ macOS 13.6 arm64 with clang 15.0.0
  + Slightly bigger differences between expected vs actual test output
    for this macOS arm64 processor test, but still very close to it.

```bash
git clone https://github.com/jafingerhut/lpc10
cd lpc10/lpc10-1.6/lpc55-C/lpc10
make
cd ..
make
```

If all went well, there should be executables with these names in the
directory `lpc10-1.6/lpc55-C`:

+ `nuke`
+ `unnuke`
+ `nuke2`
+ `unnuke2`


# Testing the code

Run these commands, after a successful build as described earlier:

```bash
cd lpc10/lpc10-1.6/data
./run-make.sh
```

Here is what "perfect" output looks like on a little-endian system.
It is OK if some decompressed samples have a small delta
(i.e. difference) with the expected decompressed audio file.  On a
big-endian system, perfect output looks the same, except all
occurrences of the word "little" would be replaced with "big".

```
$ ./run-make.sh
Endianness is: little
../lpc55-C/nuke < dam9.little-endian.spd > dam9-compressed.bits
../lpc55-C/unnuke < dam9-compressed.bits > dam9-uncompressed.little-endian.spd
../lpc55-C/compare-raw-audio dam9-out.little-endian.spd dam9-uncompressed.little-endian.spd
Delta   Number of samples that differed by delta from file 1 to 2
------  ----------------------------------------
     0  171900
------  ----------------------------------------
delta min=0  max=0  average=0.0
```


# History, copyright, and license

Author of this section of the article: Andy Fingerhut (full legal name
John Andrew Fingerhut)

I am not an intellectual property lawyer.  I only know as much about
it as any software developer who has spent a couple weeks total of
their lives thinking about copyright, patents, and software licenses.

The original README in the root directory of the extracted
[`lpc10-1.0.tar.gz`](original-code/lpc10-1.0.tar.gz) archive begins as
follows:

```
              U.S. Department of Defense
             LPC-10 2400 bps Voice Coder
                   Release 1.0
                   October 1993
```

The only place that the word "copyright" or "license" appears anywhere
in that original archive is "Copyright 1993, U.S. Department of
Defense", but that is in the directory `abtool_1.2`, which is a
utility program for comparing two audio waveforms, not the LPC-10
speech codec, which is in a separate directory.

Others have told me: "Works of the US may be considered public domain
(they are technically uncopyrightable)."

I have also been told: "If the translation is made with a grain of
creativity, its authors may hold copyright on it independently,
therefore their separate permission is needed for the work to be
free."

If the above is all correct, then according to the enhancements I have
made to the original code described below, I, John Andrew Fingerhut,
claim copyright on the C implementation in the directories
`lpc10-1.5/lpc55-C` and `lpc10-1.6/lpc55-C` of this repository, and
release it under the following license:

+ https://spdx.org/licenses/BSD-3-Clause.html
+ SPDX Full name: BSD 3-Clause "New" or "Revised" License
+ SPDX Identifier: name BSD-3-Clause

See the file [`LICENSE`](LICENSE) for a full copy of the license.

Note: If the legal answer matters to you in any significant way,
e.g. you are planning to include this code in a commercial product and
sell it for money, I suggest consulting an attorney who specializes in
intellectual property law.

WARNING: Please, software developers, take this as a warning story
that before you invest a lot of time in a project, you give some
thought to the legal status of any code you are modifying.  Thankfully
I did not spend too much of my life modifying this code, nor answering
too many questions about it later, but questions have arisen every 5
years or so from people interested in this code.

History:

In 1995 or 1996, I had become interested in a program called
[Nautilus](https://en.wikipedia.org/wiki/Nautilus_(secure_telephone)),
which was one of the first (if not the first) open source programs to
enable encrypted phone conversations.  I contacted Bill Dorsey, its
lead developer, and he mentioned that he was interested in including
speech compression in Nautilus that provided reasonable quality at
lower bits/second compressed data rates, since at the time the most
common data rates available to people from their homes were dial-up
modems with data rates ranging from 2400 bits/second to 9600
bits/second.

Through some kind of searching (Google did not exist yet), I found an
FTP site with a published implementation of the LPC-10 speech codec in
Fortran.

+ ftp://ftp.super.org/pub/speech/ in file lpc10-1.0.tar.gz

The Nautilus project web site mentions "and before that it came from
the NSA (yes, that NSA)", where NSA is the USA's National Security
Agency.

I do not believe the Internet Archive has a copy of that file
`lpc10-1.0.tar.gz` mentioned above, but I still have a copy of a file
with that name that I believe is the same as what I retrieved from the
FTP site above, and included that file in this repository in the
[`original-code`](original-code/) directory.  The time stamps on the
files in that archive range from February 1990 until October 1993,
which is earlier than my involvement with this code, so all of that
was written by others.

I started using RCS (Git had not yet been developed) to maintain my
personal modifications to the files, and according to the time stamps
in a later version I have, all of those modifications were made from
February through October in 1996.

I published a file named `lpc10-1.5.tar.gz` on my personal web page at
the time, with a version 1.5 instead of 1.0 to indicate that I felt I
had made noticeable enhancements to the original code, which included:

+ Correct what appeared to be a few bugs in the Fortran code.
+ Convert the Fortran to C using an open source conversion program f2c
+ Used a development tool called Purify to check for issues, and fixed
  the ones I was able to find using Purify.
+ The original C code used global variables to hold the state
  maintained from processing one audio frame to the next, which made
  it impossible to use the code in a program that interleaved the
  compression or decompression of multiple audio streams.  I put all
  of those global variables into C structs that were passed as
  parameters to the compression and decompression functions, enabling
  applications to be written that could do so.

I endeavored during all of my changes not to change any of the
compression algorithms, nor did I ever come to truly understand how
they worked.

+ Internet Archive - https://en.wikipedia.org/wiki/Internet_Archive
+ Nautilus secure telephone application -
  https://en.wikipedia.org/wiki/Nautilus_(secure_telephone)
+ NSA - National Security Agency
  https://en.wikipedia.org/wiki/National_Security_Agency
+ Purify - https://en.wikipedia.org/wiki/PurifyPlus
+ RCS Revision Control System -
  https://en.wikipedia.org/wiki/Revision_Control_System


# Things I would not mind if they happened

If someone wants to figure out how to take the RCS files I have
published in this repository, and make a Git repository with the same
time-ordered sequence of commits, that would be nice to have.  I have
briefly looked into tools for doing this translation and tried out one
or two, but without success.  If you succeed at something like this, I
would appreciate you contacting me.

If someone has advice that is quick and easy to follow on learning the
legal status of the original code I started from, and/or to make it
even more clear to others what copyright and license my modifications
are released under, I would be curious to know that.


# Uses of this code

It is used in the Nautilus secure telephone application:

+ https://en.wikipedia.org/wiki/Nautilus_(secure_telephone)

A slightly modified version of the C code is included in the SoX
application, with source in the `lpc10` directory of its Git
repository:

+ https://en.wikipedia.org/wiki/SoX
+ https://sourceforge.net/p/sox/code/ci/master/tree/

I believe it has been used in some other software projects, but I am
not attempting to give an exhaustive list here.
