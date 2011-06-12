BOOK_NAME=charismanie
PDFX_NAME=$(BOOK_NAME)_pdfx_1a
LINENO_PATT=\\pagewiselinenumbers
TEXINPUTS=bibleref:microtype:
TODAY=$(shell date --iso)
TARGETS=$(BOOK_NAME) $(BOOK_NAME)_numbered 
FTP_TOPDIR=calvary
FTP_PDFDIR=$(FTP_TOPDIR)/pdf
FTP_JSONDIR=$(FTP_TOPDIR)/json
FTP_EBOOKDIR=$(FTP_TOPDIR)/ebooks

# Include crocodoc conf
include ~/.crocodoc.conf

all: pdf

pdf: split split_numbered $(addsuffix .pdf,$(TARGETS))

ebooks: mobi epub

mobi: $(BOOK_NAME).mobi

epub: $(BOOK_NAME).epub

json: pdf $(addsuffix .json,$(TARGETS))

%_numbered.tex: %.tex
	sed -e 's@%$(LINENO_PATT)@$(LINENO_PATT)@' $< > $@

%.pdf: %.tex
	TEXINPUTS=$(TEXINPUTS) xelatex -shell-escape -interaction=batchmode $*
	TEXINPUTS=$(TEXINPUTS) xelatex -shell-escape -interaction=batchmode $*

%.dvi: %.tex
	-TEXINPUTS=$(TEXINPUTS) latex -interaction=batchmode $<
	-TEXINPUTS=$(TEXINPUTS) latex -interaction=batchmode $<

#%.html: %.dvi
#	# Generate PDF from DVI to make use of ifpdf
#	dvipdf $<
#	pdftohtml -noframes -enc UTF-8 -s -c $*.pdf

%.html: %.tex
	TEXINPUTS=$(TEXINPUTS) mk4ht htxelatex $< \
	   'xhtml,charset=utf-8' ' -cunihtf -utf8 -cvalidate'
	./cleanuphtml.sh $@

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
	-ncftpput -f ~/.ncftp/cc.cfg $(FTP_PDFDIR)/ *.pdf
	-ncftpput -f ~/.ncftp/cc.cfg $(FTP_JSONDIR)/ *.json
	-ncftpput -f ~/.ncftp/cc.cfg $(FTP_EBOOKDIR)/ *.mobi *.epub

%.json: %.pdf
ifeq ($(strip $(TOKEN)),)
	$(error No crocodoc token found in ~/.crocodoc.conf)
endif
	curl -F "file=@$<" -F "token=$(TOKEN)" -F "title=$* $(TODAY)" \
	   https://crocodoc.com/api/v1/document/upload > $@

spellcheck:
	find chapters/fr -name "*.tex" -exec aspell -l fr -c {} \;

crocupload: $(BOOK_NAME).json split $(BOOK_NAME)_split.json

clean:
	rm -f *.ps *.aux *.log *.out *.lol
	rm -f *.idx *.ind *.ilg *.toc *.dvi
	rm -f chapters/fr/*.aux
	rm -f chapters/en/*.aux
	rm -f make-split-stamp split-stamp
	rm -rf splits split crocupload
	rm -f *.xmpi
	rm -f *.html *.png *.css *.4tc *.tmp *.xref *.4ct
	rm -f *.epub *.mobi
	rm -f *.idv *.lg
	rm -f *.json
	# Remove only target pdf
	rm -f $(addsuffix *.pdf,$(TARGETS))


