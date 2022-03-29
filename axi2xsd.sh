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

# During extraction, we cut off the page header and footer, so their text
# doesn't mix with the XSD data.
# For this, we need to know the heights of the header and footer areas.
# You can use 'pdftotext -bbox-layout' to get a detailed XML representation of
# the page geometry, and look up the header and footer blocks there.
#PAGEHEIGHT=842 # not needed, we use FOOTER_YMIN for our calculation
PAGEWIDTH=595
HEADER_YMAX=55
FOOTER_YMIN=786

FIRST_PAGE=392
LAST_PAGE=506

# The XSD data from the PDF can contain some errors that need to be smoothed over:
# - attribute values may erroneously contain whitespace, e.g.
#   <attribute name="host" type="string" use=" optional "/>
# - " may be rendered as “ (Unicode Left Double Quotation Mark)
# - First and last page may contain extra text (e.g. heading), so extract only
#   from <?xml to </schema>.

pdftotext -layout -nopgbrk -f "$FIRST_PAGE" -l "$LAST_PAGE" -x 0 -y "$HEADER_YMAX" -W "$PAGEWIDTH" -H $((FOOTER_YMIN - HEADER_YMAX)) "$PDFPATH" - \
    | sed 's@\([[:alnum:]]\+\)="[[:space:]]\+\([[:alnum:]]\+\)[[:space:]]\+"@\1="\2"@g' \
    | sed 's/“/"/g' \
    | sed -n -e '/<?xml/,/<\/schema>/p' \


