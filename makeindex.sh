#!/bin/bash

cat chapters/fr/* | tr ' ' '\n' | tr '~' '\n' \
                  | tr ',' '\n' | tr ';' '\n' \
                  | tr ':' '\n' | tr '.' '\n' \
                  | tr '(' '\n' | tr ')' '\n' \
                  | tr '\\' '\n' | grep -v '\\' \
                  | tr "'" '\n' | grep -v '[0-9]' \
                  | tr '?' '\n' | grep -v '[\{\}]' \
                  | tr '[[:upper:]]' '[[:lower:]]' \
                  | awk '{if(length($0)>3) {print $0}}' \
                  | sort | uniq -c | sort -n \
                  | grep -v " [12345] "


