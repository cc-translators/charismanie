[![Build Status](https://img.shields.io/travis/cc-translators/charismanie/master.svg)](https://travis-ci.org/cc-translators/charismanie)
[![Latest Release](https://img.shields.io/github/release/cc-translators/charismanie.svg)](https://github.com/cc-translators/charismanie/releases)

# Requirements

 - TeXLive 2011

To build, type:

   make clean && make


# Building and uploading

Type the following:

   make


# PDF/X-1a compliance

   - Get a preflight checker... PDF Studio Pro has one: http://www.qoppa.com/pdfstudio/demo/download.html
   - See http://support.river-valley.com/wiki/index.php?title=Generating_PDF/A_compliant_PDFs_from_pdftex
     for notes on how to fix some problems ;


# Ebook generation

After converting using htlatex, I had to do some changes in the HTML/CSS:

   - Replace all long __________ lines with <hr />
   - Make sure italic text is italic : .fxlri-t-1x-x-120{font-style:italic;}
   - Make sure title page is centered : .titlepage{text-align:center;}
   - Force page breaks with style="page-break-before: always" and h2 {page-break-before: always}
   - Remove ugly stuff placed instead of ToC (for some weird reason).

These changes are currently applied with cleanuphtml.sh, but it would be better to fix them upstream.
After these changes are applied, it is best to achieve the conversion using the calibre software.
The table of contents can be properly generated by using the following XPath expressions in calibre:
   - chapters: //*[name()='h2']
   - sections: //*[name()='h3']
Resulting ebooks can be fine-tuned with the sigil software.


# Fonts

The American version from 1993 uses the following fonts:

## For the cover

"Charisma" -- Latino Elongated
"versus" -- unknown font, similar to Times New Roman, Linux Biolinum used
"Charismania" -- Goldwater"
Chuck Smith" -- very similar to Centennial, Palladino used
Back -- Adobe Sans MM, Linux Biolinum used


## For the inside

"Chapter X" -- Garamond Italic
Chapter title -- Latino Elongated
Text -- Palatino
Section title -- Garamond Italic

The Palladino and Garamond fonts used are URW fonts. The TTF files can be found at
http://www.artifex.com/downloads/






