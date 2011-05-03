#!/bin/bash

CONFFILE="$HOME/.crocodoc.conf"
. $CONFFILE

FILE="$1"
TITLE="$2"

if [ -z $TOKEN ]; then
   echo "E: TOKEN must be provided in $CONFFILE"
   exit 1
fi

if [ -z $1 ]; then
   echo "E: You must provide a file name"
   exit 1
fi 

[[ -z $TITLE ]] && TITLE="$FILE"

curl -F "file=@${FILE}" -F "token=${CROCOKEY}" -F "title=${TITLE}" \
   https://crocodoc.com/api/v1/document/upload


