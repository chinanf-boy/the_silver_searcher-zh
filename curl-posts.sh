#!/bin/bash
while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "Text read from file: $line"
    URL_NOPRO=${line:7}
    URL_REL=${URL_NOPRO#*/}
    URL_REL=${URL_REL##*/}
    curl $line -L > posts/$URL_REL.html
    html2md -i posts/$URL_REL.html -o ./mds/$URL_REL.md
done < "$1"