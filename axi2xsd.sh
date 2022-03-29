#!/bin/sh

# This script extracts the XSD-formatted "OMM AXI XML Schema" (usually
# contained in the last chapter) from Mitel's "SIP-DECT OM Application XML
# Interface" specification PDF file.
# Mitel's license does not allow redistributing the PDF file, so you'll have to
# bring your own.

if ! pdftotext -v 2>&1 | grep -q 'poppler'
then
    echo "This script expects the 'pdftotext' implementation from https://poppler.freedesktop.org/"
    exit 1
fi

PDFPATH="$1"

if ! [ -r "$PDFPATH" ]
then
    echo "Input file not found: $PDFPATH"
    exit 1
fi

# To cut off the header and footer text, we need to know their areas.
# You can use 'pdftotext -bbox-layout' to get a detailed XML representation of
# the page geometry, and look up the header and footer blocks there.
#PAGEHEIGHT=842 # not needed, we use FOOTER_YMIN for our calculation
PAGEWIDTH=595
HEADER_YMAX=55
FOOTER_YMIN=786

FIRST_PAGE=392
LAST_PAGE=506

pdftotext -layout -nopgbrk -f "$FIRST_PAGE" -l "$LAST_PAGE" -x 0 -y "$HEADER_YMAX" -W "$PAGEWIDTH" -H $((FOOTER_YMIN - HEADER_YMAX)) "$PDFPATH" - \
    | sed 's@\([[:alnum:]]\+\)="[[:space:]]\+\([[:alnum:]]\+\)[[:space:]]\+"@\1="\2"@g' \
    | sed 's/“/"/g' \
    | sed -n -e '/<?xml/,/<\/schema>/p' \


