.PHONY: all test time clean distclean dist distcheck upload distupload

all: lib/Doc/Simply/Parser/Grammar.pm test

dist:
	rm -rf inc META.y*ml
	perl Makefile.PL
	$(MAKE) -f Makefile dist

distclean tardist: Makefile
	$(MAKE) -f $< $@

lib/Doc/Simply/Parser/Grammar.pm: yapp/DCPG.yp
	yapp -m Doc::Simple::Parser::Grammar -o $@ $<

test: Makefile
	TEST_RELEASE=1 $(MAKE) -f $< $@

Makefile: Makefile.PL
	perl $<

clean: distclean

reset: clean
	perl Makefile.PL
	$(MAKE) test
