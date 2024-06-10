Sun Jun  9 08:12:35 PM EDT 2024
Andy Fingerhut (andy.fingerhut@gmail.com)

These are example input speech files for the LPC-10 speech coder:

+ `dam9.big-endian.spd`
+ `dam9.little-endian.spd`

The first file below is the result after compressing the big-endian
input file, and then decompressing, on a Sun Sparc machine, which was
big-endian.  The second was created from the first using a `dd
conv=swab` command as described later below.

+ `dam9-out.big-endian.spd`
+ `dam9-out.little-endian.spd`

Note that both of these files contain 16-bit samples with no header
before them.  Their contents differ only in whether the 16-bit samples
are big-endian, i.e. most significant byte first, or little-endian,
i.e. least significant byte first.

The `nuke` program that is part of this repository expects input files
with samples with the same endianness as the processor you are running
it on, and the `unnuke` program writes output files with the
processor's native endianness, too.

If you have files containing 16-bit samples with one endianness and
wish to convert to the other, the GNU `dd` program can do this, as
shown below.

```bash
dd conv=swab < dam9.big-endian.spd > dam9.little-endian.spd
```

`dam9.bits` is the the output of the `nuke` program that I got when
running the following command line on a Sun Sparc machine in the
1990s:

```bash
nuke < dam9.big-endian.spd > dam9.bits
```

`dam9-out.big-endian.spd` is the output of `unnuke` for the command
line:

```bash
unnuke < dam9.bits > dam9-out.big-endian.spd
```


# Examples of using `sox` utility

The `.spd` files here can be converted using the `sox` application
into other audio formats.  For example, on a little-endian machine
like an Intel-based or Apple Silicon Mac, you can use commands like
the ones shown below.

These command line options were tested with the version of `sox`
shown.

```bash
$ sox --version
sox:      SoX v14.4.2

# Some useful sox options:
# -t raw: raw input file format
# -r 8000: sample rate is 8000 Hertz
# -e signed-integer: sample format is signed integer
# -b 16: sample size is 16 bits
# --endian: specify big or little endian byte order
# -c 1: 1 sound channel, i.e. mono

SPD_SOX_OPTS="-t raw -r 8000 -e signed-integer -b 16 -c 1 --endian little"
sox $SPD_SOX_OPTS dam9.little-endian.spd dam9.aiff
sox $SPD_SOX_OPTS dam9-out.little-endian.spd dam9-out.aiff

BASENAME="josh-the-psalm-of-life"
sox ${BASENAME}.wav $SPD_SOX_OPTS ${BASENAME}.spd
nuke < ${BASENAME}.spd > ${BASENAME}.bits
unnuke < ${BASENAME}.bits > ${BASENAME}-out.spd
sox $SPD_SOX_OPTS ${BASENAME}-out.spd ${BASENAME}-out.aiff
```
