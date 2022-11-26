LISP ?= sbcl
GAME = space-turtle

build:
	$(LISP) --load $(GAME).asd \
		--load build.lisp \
		--quit

clean:
	rm -rf $(GAME)
	rm -rf bin
	rm -rf $(GAME)-win.zip
	rm -rf $(GAME)-lin.zip
	rm -rf $(GAME)-mac.zip

lin_bundle:
	mkdir $(GAME)
	mv bin $(GAME)
	cp run.sh $(GAME)
	cp NOTICE $(GAME)
	cp LICENSE $(GAME)
	zip -r $(GAME)-lin $(GAME)

win_bundle:
	mkdir $(GAME)
	mv .\bin .\$(GAME)
	cp run.bat .\$(GAME)
	cp NOTICE .\$(GAME)
	cp LICENSE .\$(GAME)
	Compress-Archive -Path .\$(GAME) -DestinationPath .\$(GAME)-win

mac_bundle:
	mv bin $(GAME)
	cp NOTICE $(GAME)
	cp LICENSE $(GAME)
	zip -r $(GAME)-mac $(GAME)
