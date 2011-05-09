#!/bin/bash

HTML="$1"
CSS="$(basename $HTML .html).css"

# Replace long lines with <hr />
sed -i 's@___\+@<hr />@' $HTML

# Center title page
echo ".titlepage {text-align:center;}" >> $CSS

# Fix missing italic
echo ".fxlri-t-1x-x-120 {font-style:italic;}" >> $CSS

# Manual page breaks
echo "h2 {page-break-before: always}" >> $CSS


# Force page breaks in intro
echo ".pagebreak {page-break-before: always}" >> $CSS
## Before thanks
sed -i 's@\(<!--l. 2--><p class="indent\)" >$@\1 pagebreak" >@' $HTML
## Before ToC
sed -i 's@\(<!--l. 17--><p class="indent\)" >$@\1 pagebreak" >@' $HTML


# TODO: try to fix the ToC


