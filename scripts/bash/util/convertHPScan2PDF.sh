#!/bin/sh

echo "converting..."
convert `ls *.png -tr` -compress zip -resize 1020x1320 -density 120x120 -units PixelsPerInch $1.pdf
