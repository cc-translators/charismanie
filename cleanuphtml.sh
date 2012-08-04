#!/bin/bash

HTML="$1"
CSS="$(basename $HTML .html).css"

## Accents
for class in "fxlrc-t1-" "fxlrc-t1-x-x-120" "fxlbc-t1-x-x-248" "fxlbc-t1-x-x-144" "cmcsc-10x-x-120"; do
   while read c r; do
      sed -i "s@\(\"$class\">\)$c\([^<]*\)<@\1<span class=\"small-caps\">$r\2</span><@" $HTML
   done <<<"é é
è è
ê ê
ï ï
î î
ﬁ ﬁ
ﬀ ﬀ
ﬂ ﬂ
ﬃ  ﬃ
â â
à à
ù ù
û û
ô ô"
done


# Lettrines
echo ".lettrine:first-letter{font-size:6em;margin-right:3px;display:inline;line-height:0.5em;color:gray;float:left;}" >> $CSS
sed -i '/<h2/,/<h3/ { s@\(<p class="noindent\)" >@\1 lettrine" >@  }' $HTML

## And restore indentation in the beginning of sections
sed -i '/<h2/,/<\/html/ { s@"noindent"@"indent"@ }' $HTML


# TODO: try to fix the ToC


