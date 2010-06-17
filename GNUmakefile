.PHONY: all example

BUILD := lib/Doc/Simply/Render/HTML/TT.pm
.PHONY: lib/Doc/Simply/Render/HTML/TT.pm

all: $(BUILD)

lib/Doc/Simply/Render/HTML/TT.pm: assets/tt/TT.pm assets/tt/*.tt.html assets/css/*
	tpage $< | dos2unix > $@

example: $(BUILD)
	cat eg/example.js | ./script/doc-simply > example.html
	cat example.html
