EXEC_DIR=../lpc55-C

test: $(EXEC_DIR)/nuke $(EXEC_DIR)/unnuke
	echo "Endianness is: $(ENDIANNESS)"
	if [ ! -r dam9.$(ENDIANNESS)-Endian.spd ]; then echo "No such file dam9.$(ENDIANNESS)-Endian.spd.  If you ran 'make', try instead: ./run-make.sh"; exit 1; fi
	$(EXEC_DIR)/nuke < dam9.$(ENDIANNESS)-Endian.spd > dam9-compressed.bits
	$(EXEC_DIR)/unnuke < dam9-compressed.bits > dam9-uncompressed.$(ENDIANNESS)-Endian.spd
	$(EXEC_DIR)/compare-raw-audio dam9-out.$(ENDIANNESS)-Endian.spd dam9-uncompressed.$(ENDIANNESS)-Endian.spd

clean:
	/bin/rm -f dam9-compressed.bits dam9-uncompressed.*-Endian.spd
