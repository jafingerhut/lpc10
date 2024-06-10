# Introduction

This repository contains two implementations, one in Fortran, another
in C, for a [speech
codec](https://en.wikipedia.org/wiki/Category:Speech_codecs) called
LPC-10.  It can compress human speech audio to 2400 bits per second.
Note that speech codecs are specialized for compressing audio
containing human speech, and is not intended to be used for arbitrary
audio signals.

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

+ Ubuntu 20.04 aarch64 with GCC 9.4.0
+ Ubuntu 24.04 x86_64 with GCC 13.2.0

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

TODO


# History, copyright, and license

Author of this section of the article: Andy Fingerhut

Because of the history of this implementation, the copyright and
license status is still not completely clear to me, for reasons
discussed further below.  It _might_ be in the public domain, but if
the legal answer matters to you in any significant way, I suggest
consulting an attorney who specialies in intellectual property law.

WARNING: Please, software developers, take this as a warning story
that before you invest a lot of time in a project, you give some
thought to the legal status of any code you are modifying.  Thankfully
I did not spend too much of my life modifying this code, nor answering
too many questions about it later, but questions have arisen every 5
years or so from people interested in this code.

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

After publishing the code, occasionally someone would ask me about the
copyright and license that the code was released under.  I always
answered where I obtained the original code, and as far as I could
tell, there was no copyright notice or license in the original code
(please check for yourself in the file `lpc10-1.0.tar.gz` if you are
curious), and I did not wish to restrict the code's use any more than
the original was.

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
clear to others what copyright and license my modifications are
released under, I would be curious to know that.  I am perfectly happy
to say any of the following, if it is true or can easily be made true:

+ Public domain, or copyright by "insert-name-here"
+ Some permissive open source license such as BSD, MIT, Apache 2, etc.
  I do not have interest in releasing it under any variation of the GPL.


# Uses of this code

It is used in the Nautilus secure telephone application:

+ https://en.wikipedia.org/wiki/Nautilus_(secure_telephone)

A slightly modified version of the C code is included in the SoX
application, with source in the `lpc10` directory of its Git repo:

+ https://en.wikipedia.org/wiki/SoX
+ https://sourceforge.net/p/sox/code/ci/master/tree/
