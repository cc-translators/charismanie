BOOK_NAME=charismanie
PDFX_NAME=$(BOOK_NAME)_pdfx_1a
LINENO_PATT=\\pagewiselinenumbers
TEXINPUTS=microtype:
TODAY=$(shell date --iso)
TARGETS=$(BOOK_NAME) $(BOOK_NAME)_numbered $(BOOK_NAME)_interior
FTP_TOPDIR=calvary
FTP_PDFDIR=$(FTP_TOPDIR)/pdf
FTP_JSONDIR=$(FTP_TOPDIR)/json
FTP_EBOOKDIR=$(FTP_TOPDIR)/ebooks

CHAPTERS_FR=$(shell find $(CURDIR)/chapters/fr -type f -name '*.tex')
CHAPTERS_EN=$(shell find $(CURDIR)/chapters/en -type f -name '*.tex')

# Ebook settings
KINDLE_PATH=/documents/raphael
AUTHOR=Chuck Smith
LANGUAGE=fr
PUBDATE=$(shell date)
COVER=charismanie_cover_sans_lulu_firstpage.png
TITLE=Charismatique ou charismaniaque ?

EBOOK_CONVERT_OPTS=--authors "$(AUTHOR)" --title "$(TITLE)" --language "$(LANGUAGE)" --pubdate "$(PUBDATE)" --page-breaks-before "//*[name()='h1' or name()='h2']" --cover "$(COVER)" --use-auto-toc  --level1-toc "//*[name()='h2']" --level2-toc "//*[name()='h3']" --minimum-line-height=0.4 --font-size-mapping "12,12,14,16,18,20,26,64"

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

%.pdf: %.tex $(CHAPTERS_FR) $(CHAPTERS_EN)
	TEXINPUTS=$(TEXINPUTS) lualatex -shell-escape -interaction=batchmode $*
	TEXINPUTS=$(TEXINPUTS) lualatex -shell-escape -interaction=batchmode $*

%.dvi: %.tex
	-TEXINPUTS=$(TEXINPUTS) latex -interaction=batchmode $<
	-TEXINPUTS=$(TEXINPUTS) latex -interaction=batchmode $<

#%.html: %.dvi
#	# Generate PDF from DVI to make use of ifpdf
#	dvipdf $<
#	pdftohtml -noframes -enc UTF-8 -s -c $*.pdf

%_split.html: %.tex
	TEXINPUTS=$(TEXINPUTS) htlatex $< \
	   'ebook.cfg,xhtml,2,charset=utf-8' ' -cunihtf -utf8 -cvalidate'
	bash cleanuphtml.sh $*.html

%.html: %.tex
	TEXINPUTS=$(TEXINPUTS) htlatex $< \
	   'ebook.cfg,xhtml,charset=utf-8' ' -cunihtf -utf8 -cvalidate'
	bash cleanuphtml.sh $@

%_embedded.epub: %.epub
	rm -rf $*
	unzip  -d $* $<
	cp -r fonts $*/
	cat fonts.css $*/stylesheet.css > new.css
	mv new.css $*/stylesheet.css
	zip -r $@ $*/*

%.epub: %.html
	ebook-convert $< $@ $(EBOOK_CONVERT_OPTS) --preserve-cover-aspect-ratio

%.mobi: %.html
	ebook-convert $< $@ $(EBOOK_CONVERT_OPTS) --mobi-file-type "both"

%-to-kindle: %.mobi
	# cp -f doesn't work, we need to remove
	ebook-device rm "$(KINDLE_PATH)/$<"
	-ebook-device mkdir "$(KINDLE_PATH)"
	ebook-device cp $< "prs500:$(KINDLE_PATH)/$<"

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
	rm -f $(addsuffix .pdf,$(TARGETS))


