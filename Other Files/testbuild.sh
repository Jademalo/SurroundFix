#!/bin/sh
cd ..
curl -s https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh | bash -s -- -d -g classic
rm -r .release/SurroundFixClassic
cp -r .release/SurroundFix .release/SurroundFixClassic
curl https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh | bash -s -- -d



## This script updates the packager, then builds both a standard and classic
## release so I can test everything is working

## All builds done with the release script will be non-debug, the point of debug is to have
## a section of code in a debug bracket that runs by default, but that after building gets
## removed or replaced by a section in a non-debug bracket

## -s -- is necessary after bash to pass the arguments correctly into the shell script downloaded with curl
