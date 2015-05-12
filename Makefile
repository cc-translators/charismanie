BOOK_NAME=charismanie
PDFX_NAME=$(BOOK_NAME)_pdfx_1a
LINENO_PATT=\\pagewiselinenumbers
TEXINPUTS=microtype:
FONTSDIR=fonts
TODAY=$(shell date --iso)
TARGETS=$(BOOK_NAME) $(BOOK_NAME)_numbered $(BOOK_NAME)_interior
LATEX_INTERACTION=batchmode
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
PUBDATE=$(shell date +'%Y-%m-%d')
COVER=cover/charismanie_cover_black_firstpage.png
TITLE=Charismatique ou charismaniaque ?

EBOOK_CONVERT_OPTS=--authors "$(AUTHOR)" --title "$(TITLE)" --language "$(LANGUAGE)" --pubdate "$(PUBDATE)" --page-breaks-before "//*[name()='h1' or name()='h2']" --cover "$(COVER)" --use-auto-toc  --level1-toc "//*[name()='h2']" --level2-toc "//*[name()='h3']" --minimum-line-height=0.4 --font-size-mapping "10,12,14,16,18,20,26,64"

all: pdf

pdf: split split_numbered $(addsuffix .pdf,$(TARGETS))

ebooks: mobi epub

mobi: $(BOOK_NAME).mobi

epub: $(BOOK_NAME).epub

json: pdf $(addsuffix .json,$(TARGETS))

%_numbered.tex: %.tex
	sed -e 's@%$(LINENO_PATT)@$(LINENO_PATT)@' $< > $@

%.pdf: %.tex $(CHAPTERS_FR) $(CHAPTERS_EN)
	OSFONTDIR=$(FONTSDIR) TEXINPUTS=$(TEXINPUTS) lualatex -shell-escape -interaction=$(LATEX_INTERACTION) $*
	OSFONTDIR=$(FONTSDIR) TEXINPUTS=$(TEXINPUTS) lualatex -shell-escape -interaction=$(LATEX_INTERACTION) $*

%.dvi: %.tex
	-OSFONTDIR=$(FONTSDIR) TEXINPUTS=$(TEXINPUTS) latex -interaction=$(LATEX_INTERACTION) $<
	-OSFONTDIR=$(FONTSDIR) TEXINPUTS=$(TEXINPUTS) latex -interaction=$(LATEX_INTERACTION) $<

#%.html: %.dvi
#	# Generate PDF from DVI to make use of ifpdf
#	dvipdf $<
#	pdftohtml -noframes -enc UTF-8 -s -c $*.pdf

%_split.html: %.tex
	OSFONTDIR=$(FONTSDIR) TEXINPUTS=$(TEXINPUTS) htlatex $< \
	   'ebook.cfg,xhtml,2,charset=utf-8' ' -cunihtf -utf8 -cvalidate'
	bash cleanuphtml.sh $*.html

%.html: %.tex
	OSFONTDIR=$(FONTSDIR) TEXINPUTS=$(TEXINPUTS) htlatex $< \
	   'ebook.cfg,xhtml,charset=utf-8' ' -cunihtf -utf8 -cvalidate'
	bash cleanuphtml.sh $@

%_embedded.epub: %.epub
	rm -rf $*
	unzip  -d $* $<
	cp -r fonts $*/
	# Add fons to stylesheet.css
	cat fonts.css >> $*/stylesheet.css
	# Insert fonts into content.opf
	sed -i '/<manifest>/ r fonts.content' $*/content.opf
	# Regenerate zip
	cd $* && zip -Xr9D $(CURDIR)/$@ mimetype *

%.epub: %.html
	ebook-convert $< $@ $(EBOOK_CONVERT_OPTS) --preserve-cover-aspect-ratio

%.mobi: %.epub
	#ebook-convert $< $@ $(EBOOK_CONVERT_OPTS) --mobi-file-type "both"
	kindlegen $<

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


spellcheck:
	find chapters/fr -name "*.tex" -exec aspell -l fr -c {} \;

crocupload: $(BOOK_NAME).json split $(BOOK_NAME)_split.json

clean:
	rm -f *.ps *.aux *.log *.out *.lol
	rm -f *.idx *.ind *.ilg *.toc *.dvi
	rm -f chapters/fr/*.aux
	rm -f chapters/en/*.aux
	rm -f make-split-stamp split-stamp
	rm -rf splits split
	rm -f *.xmpi
	rm -f *.html *.4tc *.tmp *.xref *.4ct
	rm -f *.epub *.mobi
	rm -f *.idv *.lg
	rm -f *.json
	# Remove only target pdf
	rm -f $(addsuffix .pdf,$(TARGETS))

microtype.tar.xz:
	wget http://tlcontrib.metatex.org/2010/archive/microtype.tar.xz

upgrade-microtype: microtype.tar.xz
	rm -rf microtype
	tar xf $< --strip-components=2

