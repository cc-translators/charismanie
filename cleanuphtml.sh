#!/bin/bash

HTML="$1"
CSS="$(basename $HTML .html).css"

# Remove space before nbsp
sed -i "s@ *&nbsp; *@\&nbsp;@g" $HTML

