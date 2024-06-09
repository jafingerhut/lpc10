sparccompiler-f77:	localtest.f
	# Print version number of compiler and other components with -V option
	f77 -V $? -o $@
	ls -l $@
	ldd $@
	$@

SIESTA_BASE=/home/cs/student/jaf
SOLARIS_LIB=$(SIESTA_BASE)/lib
SOLARIS_INCLUDE=$(SIESTA_BASE)/include

solaris-f2c-gcc:
	$(MAKE) f2c-gcc EXECUTABLE_NAME=solaris-f2c-gcc-prog CFLAGS="-I$(SOLARIS_INCLUDE) -L$(SOLARIS_LIB)"


JOSHUA_BASE=/home/jaf
LINUX_LIB=$(JOSHUA_BASE)/lib
LINUX_INCLUDE=$(JOSHUA_BASE)/include

linux-f2c-gcc:
	$(MAKE) f2c-gcc EXECUTABLE_NAME=linux-f2c-gcc-prog CFLAGS="-I$(LINUX_INCLUDE) -L$(LINUX_LIB)"


# Generate ANSI C code
F2C=f2c -A

f2c-gcc:	localtest.f
	$(F2C) $?
	# Print version number of f2c
	head -4 $(basename $?).c
	# Print version number of gcc
	gcc -v
	gcc $(CFLAGS) $(basename $?).c -lf2c -lm -o $(EXECUTABLE_NAME)
	ls -l $(EXECUTABLE_NAME)
	ldd $(EXECUTABLE_NAME)
	$(EXECUTABLE_NAME)
