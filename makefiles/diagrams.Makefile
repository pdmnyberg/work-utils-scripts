SRCDIR?=src
OUTDIR?=output
SOURCES=$(wildcard $(SRCDIR)/*.gv.txt)
FORMAT?=png


$(OUTDIR)/%.$(FORMAT): $(SRCDIR)/%.gv.txt
	mkdir -p $(OUTDIR) && \
	echo "Building: $@: $^" && \
	dot -T$(FORMAT) -o$@ $<

all: $(SOURCES:$(SRCDIR)/%.gv.txt=$(OUTDIR)/%.$(FORMAT))
