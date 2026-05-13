SRCDIR?=src
OUTDIR?=output
SOURCES=$(wildcard $(SRCDIR)/*.md)

DOC_OUTDIR?=$(OUTDIR)/documents
DOC_SRCDIR=$(SRCDIR)/documents
DOC_SOURCES=$(wildcard $(DOC_SRCDIR)/*.md)

RSCDIR?=resources/external
COMMON_STYLE?=$(SRCDIR)/meerkatsstyle.tex


all: \
	$(RSCDIR)/all-images \
	$(SOURCES:$(SRCDIR)/%.md=$(OUTDIR)/%.pdf) \
	$(DOC_SOURCES:$(DOC_SRCDIR)/%.md=$(DOC_OUTDIR)/%.pdf)

$(RSCDIR)/git-logo.png:
	curl \
		"https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Git-logo.svg/1024px-Git-logo.svg.png" \
		-o "$@"

$(RSCDIR)/long-road.jpg:
	curl \
		"https://images.unsplash.com/photo-1583778957124-763fd4826122?q=80&w=500&h=2000&fmt=jpeg&fit=crop" \
		-o "$@"

$(RSCDIR)/road-sign.jpg:
	curl \
		"https://images.unsplash.com/photo-1530518618982-f7f23af0e533?q=80&w=500&h=2000&fmt=jpeg&fit=crop" \
		-o "$@"

$(RSCDIR)/crisp.jpg:
	curl \
		"https://images.unsplash.com/photo-1604565011092-c0fa4416f80f?q=80&w=500&h=2000&fmt=jpeg&fit=crop" \
		-o "$@"

$(RSCDIR)/rubberduck.jpg:
	curl \
		"https://images.unsplash.com/photo-1603736087997-5daec6092347?q=80&w=500&h=2000&fmt=jpeg&fit=crop" \
		-o "$@"

$(RSCDIR)/bird-ringing.jpg:
	curl \
		"https://images.unsplash.com/photo-1758013528200-2a78ce228b72?q=80&w=700&h=2000&fmt=jpeg&fit=crop" \
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
	$(RSCDIR)/git-logo.png \
	$(RSCDIR)/long-road.jpg \
	$(RSCDIR)/road-sign.jpg \
	$(RSCDIR)/crisp.jpg \
	$(RSCDIR)/rubberduck.jpg \
	$(RSCDIR)/bird-ringing.jpg
	touch $@
