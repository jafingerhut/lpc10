EXEC_DIR=../lpc55-C

test: $(EXEC_DIR)/nuke $(EXEC_DIR)/unnuke
	echo "Endianness is: $(ENDIANNESS)"
	$(EXEC_DIR)/nuke < dam9.$(ENDIANNESS)-Endian.spd > dam9-compressed.bits
	$(EXEC_DIR)/unnuke < dam9-compressed.bits > dam9-uncompressed.$(ENDIANNESS)-Endian.spd
	$(EXEC_DIR)/compare-raw-audio dam9-out.$(ENDIANNESS)-Endian.spd dam9-uncompressed.$(ENDIANNESS)-Endian.spd

clean:
	/bin/rm -f dam9-compressed.bits dam9-uncompressed.*-Endian.spd
