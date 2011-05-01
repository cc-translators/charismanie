#!/bin/bash

. crocupload.conf

FILE="$1"
TITLE="$2"

if [ -z $CROCOKEY ]; then
   echo "E: CROCOKEY must be provided in crocupload.conf"
   exit 1
fi

if [ -z $1 ]; then
   echo "E: You must provide a file name"
   exit 1
fi 

[[ -z $TITLE ]] && TITLE="$FILE"

curl -F "file=@${FILE}" -F "token=${CROCOKEY}" -F "title=${TITLE}" \
   https://crocodoc.com/api/v1/document/upload


