#!/bin/bash

HTML="$1"
CSS="$(basename $HTML .html).css"

# Remove space before nbsp
sed -i ':a;N;$!ba;s@[\n ]*&nbsp;[\n ]*@\&nbsp;@g' $HTML

