BOOK_NAME=charismanie
LINENO_PATT=\\pagewiselinenumbers
TEXINPUTS=bibleref:

all: $(BOOK_NAME).pdf $(BOOK_NAME)_numbered.pdf split split_numbered


%_numbered.tex: %.tex
	sed -e 's@%$(LINENO_PATT)@$(LINENO_PATT)@' $< > $@

%.pdf: %.tex
	TEXINPUTS=$(TEXINPUTS) pdflatex -interaction=batchmode $<
	TEXINPUTS=$(TEXINPUTS) pdflatex -interaction=batchmode $<

make-split: make-split-stamp
make-split-stamp:
	-./split.sh
	touch make-split-stamp

split: make-split $(BOOK_NAME)_split.pdf

split_numbered: make-split $(BOOK_NAME)_split_numbered.pdf

upload:
	ncftpput -f ~/.ncftp/cc.cfg calvary/ *.pdf

clean:
	rm -f *.pdf *.ps *.aux *.log *.out *.lol
	rm -f *.idx *.ind *.ilg *.toc *.dvi
	rm -f chapters/fr/*.aux
	rm -f chapters/en/*.aux
	rm -f make-split-stamp split-stamp
	rm -rf splits


