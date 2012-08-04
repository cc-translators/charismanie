#!/bin/bash

HTML="$1"
CSS="$(basename $HTML .html).css"

# Replace long lines with <hr />
sed -i 's@___\+@<hr />@' $HTML

# Wrap text in pure HTML
echo "body { padding: 0 300px 0 300px }" >> $CSS

# Center title page
echo ".titlepage {text-align:center;}" >> $CSS

# Fix missing italic
echo ".fxlri-t-1x-x-120 {font-style:italic;}" >> $CSS

# Manual page breaks
echo "h2 {page-break-before: always}" >> $CSS


## Accents
for class in "fxlrc-t1-" "fxlrc-t1-x-x-120" "fxlbc-t1-x-x-248" "fxlbc-t1-x-x-144" "cmcsc-10x-x-120"; do
   while read c r; do
      sed -i "s@\(\"$class\">\)$c\([^<]*\)<@\1<span class=\"small-caps\">$r\2</span><@" $HTML
   done <<<"é É
è È
ê Ê
ï Ï
î Î
ﬁ FI
ﬀ  FF
ﬂ FL
ﬃ   FFI
â Â
à À
ù Ù
û Û
ô Ô"
done

## Ligatures
while read c r; do
   sed -i "s@\"small-caps\">$c<@\"small-caps\">$r<@" $HTML
done <<<"ﬁ FI
ﬀ  FF
ﬂ FL
ﬃ   FFI"


# Lettrines
echo ".lettrine:first-letter{font-size:6em;margin-right:3px;display:inline;line-height:0.5em;color:gray;float:left;}" >> $CSS
sed -i '/<h2/,/<h3/ { s@\(<p class="noindent\)" >@\1 lettrine" >@  }' $HTML

## And restore indentation in the beginning of sections
sed -i '/<h2/,/<\/html/ { s@"noindent"@"indent"@ }' $HTML


# TODO: try to fix the ToC


