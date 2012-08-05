#!/bin/bash

HTML="$1"
CSS="$(basename $HTML .html).css"

# Remove space before nbsp
sed -i "s@ *&nbsp; *@\&nbsp;@g" $HTML

## And restore indentation in the beginning of sections
sed -i '/<h2/,/<\/html/ { s@"noindent"@"indent"@ }' $HTML

