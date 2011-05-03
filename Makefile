BOOK_NAME=charismanie
PDFX_NAME=$(BOOK_NAME)_pdfx_1a
LINENO_PATT=\\pagewiselinenumbers
TEXINPUTS=bibleref:
TODAY=$(shell date --iso)
TARGETS=$(BOOK_NAME) $(BOOK_NAME)_numbered 
FTP_TOPDIR=calvary
FTP_JSONDIR=$(FTP_TOPDIR)/json

all: pdf

pdf: split split_numbered $(addsuffix .pdf,$(TARGETS))

json: pdf $(addsuffix .json,$(TARGETS))


%_numbered.tex: %.tex
	sed -e 's@%$(LINENO_PATT)@$(LINENO_PATT)@' $< > $@

%.pdf: %.tex
	TEXINPUTS=$(TEXINPUTS) pdflatex -interaction=batchmode $<
	TEXINPUTS=$(TEXINPUTS) pdflatex -interaction=batchmode $<

%.dvi: %.tex
	-TEXINPUTS=$(TEXINPUTS) latex -interaction=batchmode $<
	-TEXINPUTS=$(TEXINPUTS) latex -interaction=batchmode $<

%.html: %.dvi
	# Generate PDF from DVI to make use of ifpdf
	dvipdf $<
	pdftohtml -noframes -enc UTF-8 -s -c $*.pdf

%.epub: %.html
	ebook-convert $< $@

%.mobi: %.html
	ebook-convert $< $@
	

make-split: make-split-stamp
make-split-stamp:
	./split.sh
	touch make-split-stamp

split: make-split $(BOOK_NAME)_split.pdf

split_numbered: make-split $(BOOK_NAME)_split_numbered.pdf

upload:
	ncftpput -f ~/.ncftp/cc.cfg $(FTP_TOPDIR)/ *.pdf
	ncftpput -f ~/.ncftp/cc.cfg $(FTP_JSONDIR)/ *.json

%.json: %.pdf
	./crocupload.sh $< "$* $(TODAY)" > $@
	grep -q "error\|went wrong" $@ && \
	   echo "Upload failed. See $@ for more info." && exit 1

crocupload: $(BOOK_NAME).json split $(BOOK_NAME)_split.json

clean:
	rm -f *.pdf *.ps *.aux *.log *.out *.lol
	rm -f *.idx *.ind *.ilg *.toc *.dvi
	rm -f chapters/fr/*.aux
	rm -f chapters/en/*.aux
	rm -f make-split-stamp split-stamp
	rm -rf splits split crocupload
	rm -f *.xmpi
	rm -f *.html *.png
	rm -f *.epub *.mobi
	rm -f *.idv *.lg
	rm -f *.json


