BOOK_NAME=charismanie
PDFX_NAME=$(BOOK_NAME)_pdfx_1a
LINENO_PATT=\\pagewiselinenumbers
TEXINPUTS=bibleref:
TODAY=$(shell date --iso)

all: $(BOOK_NAME).pdf $(BOOK_NAME)_numbered.pdf split split_numbered $(PDFX_NAME).pdf


%_numbered.tex: %.tex
	sed -e 's@%$(LINENO_PATT)@$(LINENO_PATT)@' $< > $@

%.pdf: %.tex
	TEXINPUTS=$(TEXINPUTS) pdflatex -interaction=batchmode $<
	TEXINPUTS=$(TEXINPUTS) pdflatex -interaction=batchmode $<

make-split: make-split-stamp
make-split-stamp:
	./split.sh
	touch make-split-stamp

split: make-split $(BOOK_NAME)_split.pdf

split_numbered: make-split $(BOOK_NAME)_split_numbered.pdf

upload:
	ncftpput -f ~/.ncftp/cc.cfg calvary/ *.pdf

crocupload: $(BOOK_NAME).pdf split
	cp $(BOOK_NAME).pdf $(BOOK_NAME)_$(TODAY).pdf
	./crocupload.sh "$(BOOK_NAME)_$(TODAY).pdf" "$(BOOK_NAME) $(TODAY)"
	cp $(BOOK_NAME)_split.pdf $(BOOK_NAME)_split_$(TODAY).pdf
	./crocupload.sh "$(BOOK_NAME)_split_$(TODAY).pdf" "$(BOOK_NAME) split $(TODAY)"

clean:
	rm -f *.pdf *.ps *.aux *.log *.out *.lol
	rm -f *.idx *.ind *.ilg *.toc *.dvi
	rm -f chapters/fr/*.aux
	rm -f chapters/en/*.aux
	rm -f make-split-stamp split-stamp
	rm -rf splits split
	rm -f *.xmpi


