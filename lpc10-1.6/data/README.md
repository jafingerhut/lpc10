Sun Jun  9 08:12:35 PM EDT 2024
Andy Fingerhut (andy.fingerhut@gmail.com)

These are example input speech files for the LPC-10 speech coder:

+ `dam9.Big-Endian.spd`
+ `dam9.Little-Endian.spd`

The first file below is the result after compressing the big-endian
input file, and then decompressing, on a Sun Sparc machine, which was
big-endian.  The second was created from the first using a `dd
conv=swab` command as described later below.

+ `dam9-out.Big-Endian.spd`
+ `dam9-out.Little-Endian.spd`

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
dd conv=swab < dam9.Big-Endian.spd > dam9.Little-Endian.spd
```

`dam9.bits` is the the output of the `nuke` program that I get when
running the following command line on a Sun Sparc machine in the
1990s:

```bash
nuke < dam9.Big-Endian.spd > dam9.bits
```

`dam9-out.Big-Endian.spd` is the output of `unnuke` for the command
line:

```bash
unnuke < dam9.bits > dam9-out.Big-Endian.spd
```

The `.spd` files here can be converted using the `sox` application
into other audio formats.  For example, on a big-endian machine like a
PowerPC Mac, you can use this:

```bash
# -t raw: raw input file format
# -r 8000: sample rate is 8000 Hertz
# -s: sample format is signed linear
# -w: sample data size is 16-bit words
# -c 1: 1 sound channel, i.e. mono

sox -t raw -r 8000 -s -w -c 1 dam9.spd dam9.aiff
sox -t raw -r 8000 -s -w -c 1 dam9-out.spd dam9-out.aiff


sox josh-the-psalm-of-life.wav -t raw -r 8000 -s -w -c 1 josh-the-psalm-of-life.spd
nuke < josh-the-psalm-of-life.spd > josh-the-psalm-of-life.bits
unnuke < josh-the-psalm-of-life.bits > josh-the-psalm-of-life-out.spd
sox -t raw -r 8000 -s -w -c 1 josh-the-psalm-of-life-out.spd josh-the-psalm-of-life-out.aiff


sox owen-the-germ.wav -t raw -r 8000 -s -w -c 1 owen-the-germ.spd
nuke < owen-the-germ.spd > owen-the-germ.bits
unnuke < owen-the-germ.bits > owen-the-germ-out.spd
sox -t raw -r 8000 -s -w -c 1 owen-the-germ-out.spd owen-the-germ-out.aiff
```
