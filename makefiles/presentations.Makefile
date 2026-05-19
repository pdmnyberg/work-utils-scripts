SRCDIR?=src
OUTDIR?=output
SOURCES=$(wildcard $(SRCDIR)/*.md)

DOC_OUTDIR?=$(OUTDIR)/documents
DOC_SRCDIR=$(SRCDIR)/documents
DOC_SOURCES=$(wildcard $(DOC_SRCDIR)/*.md)

RSCDIR?=resources
EXT_RSCDIR?=$(RSCDIR)/external
EXT_RESOURCES=$(wildcard $(RSCDIR)/*.url.txt)
COMMON_STYLE?=$(SRCDIR)/common_style.tex


all: \
	$(RSCDIR)/all-images \
	$(SOURCES:$(SRCDIR)/%.md=$(OUTDIR)/%.pdf) \
	$(DOC_SOURCES:$(DOC_SRCDIR)/%.md=$(DOC_OUTDIR)/%.pdf)


$(EXT_RSCDIR)/%: \
	$(RSCDIR)/%.url.txt

	SRCURL="$(RSCDIR)/$*.url.txt" && \
	curl \
		`head -n 1 $$SRCURL` \
		-o "$@"

$(DOC_OUTDIR)/%.pdf: \
	$(DOC_SRCDIR)/%.md

	mkdir -p $(DOC_OUTDIR) && \
	echo "Building: $@: $^" && \
	pandoc --pdf-engine=xelatex \
		-o $@ \
		$<

$(OUTDIR)/%.pdf: \
	$(SRCDIR)/%.md \
	$(COMMON_STYLE) \
	$(SRCDIR)/overrides/%.md.tex

	mkdir -p $(OUTDIR) && \
	HEADEREXT="$(SRCDIR)/overrides/$*.md.tex" && \
	echo "Building: $@: $^" && \
	pandoc --pdf-engine=xelatex \
		-t beamer \
		--include-in-header="$(COMMON_STYLE)" \
		`[ -f "$$HEADEREXT" ] && echo "--include-in-header=$$HEADEREXT"` \
		-o $@ \
		$<

$(OUTDIR)/%.pdf: \
	$(SRCDIR)/%.md \
	$(COMMON_STYLE)

	mkdir -p $(OUTDIR) && \
	echo "Building: $@: $^" && \
	pandoc --pdf-engine=xelatex \
		-t beamer \
		--include-in-header="$(COMMON_STYLE)" \
		-o $@ \
		$<

$(RSCDIR)/all-images: \
	$(patsubst $(RSCDIR)/%.url.txt,$(EXT_RSCDIR)/%,$(EXT_RESOURCES))
	touch $@
