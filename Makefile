ASM=sdasz80
AFLAGS=-p -g -o
ODIR=obj
SDIR=src
_RELS=ti83plus.rel picvar.rel floatingpoint.rel iongraphics.rel appvar.rel \
       output.rel prgm.rel rand.rel time.rel hardware.rel keyboard.rel
RELS := $(addprefix $(ODIR)/,$(_RELS))
LIB=c_ti83p.lib

.PHONY: all clean

all: $(LIB) tios_crt0.rel

$(LIB): $(RELS)
	sdar -rc $(LIB) $(RELS)

tios_crt0.rel: $(SDIR)/tios_crt0.s
	$(ASM) $(AFLAGS) $@ $<

$(ODIR)/%.rel: $(SDIR)/%.asm | $(ODIR)
	$(ASM) $(AFLAGS) $@  $<

$(ODIR):
	mkdir obj

clean:
	rm -f $(LIB) tios_crt0.rel
	rm -r -f obj
