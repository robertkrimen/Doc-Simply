.PHONY: all test time clean distclean dist distcheck upload distupload example

BUILD := lib/Doc/Simply/Render/HTML/TT.pm
.PHONY: lib/Doc/Simply/Render/HTML/TT.pm

all: $(BUILD) test

lib/Doc/Simply/Render/HTML/TT.pm: assets/tt/TT.pm assets/tt/frame.tt.html
	tpage $< > $@

example: $(BUILD)
	cat example.js | ./script/doc-simply >example.html
	cat example.html

dist:
	rm -rf inc META.y*ml
	perl Makefile.PL
	$(MAKE) -f Makefile dist

install distclean tardist: Makefile
	$(MAKE) -f $< $@

test: Makefile
	TEST_RELEASE=1 $(MAKE) -f $< $@

Makefile: Makefile.PL
	perl $<

clean: distclean

reset: clean
	perl Makefile.PL
	$(MAKE) test
