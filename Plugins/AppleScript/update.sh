#!/bin/bash

for k in *.applescript ; do
  BASE=`basename "$k" .applescript`
  osacompile -l AppleScript -d -o "${BASE}.scpt" "$k"
done
