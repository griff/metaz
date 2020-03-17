#!/bin/bash
if [ -z "$1" ]; then
  VERSION="$(sw_vers -productVersion)"
  echo "Missing version."
else
  VERSION="$1"
  shift
fi
VERSION_V="$(cut -d "." -f2 <<<"$VERSION")"

if [ -z "$1" ]; then
  echo "Using version $1"
  find App -name *.applescript -exec ./compile-applescripts.sh "$VERSION" compile {} \;
  find Plugins -name *.applescript -exec ./compile-applescripts.sh "$VERSION" compile {} \;
elif [ "$1" == "compile" ]; then
  k="$2"
  BASE="$(basename "$k" .applescript)"
  DIR="$(dirname "$k")"
  echo "Base $BASE"
  if [ -d "${DIR}/${BASE}.scptd" ]; then
    if /usr/libexec/PlistBuddy -c "Print :LSMinimumSystemVersion" "${DIR}/${BASE}.scptd/Contents/Info.plist" &> /dev/null ; then
      MIN="$(/usr/libexec/PlistBuddy -c "Print :LSMinimumSystemVersion" "${DIR}/${BASE}.scptd/Contents/Info.plist")"
      MIN_V="$(cut -d "." -f2 <<<"$MIN")"
      echo "Minimum $MIN $MIN_V"
    fi
    if /usr/libexec/PlistBuddy -c "Print :MZMaximumSystemVersion" "${DIR}/${BASE}.scptd/Contents/Info.plist" &> /dev/null ; then
      MAX="$(/usr/libexec/PlistBuddy -c "Print :MZMaximumSystemVersion" "${DIR}/${BASE}.scptd/Contents/Info.plist")"
      MAX_V="$(cut -d "." -f2 <<<"$MAX")"
      echo "Maximum $MAX $MAX_V"
    fi
  fi
  CHECK=1
  if [ -n "$MIN_V" ] && [ "$VERSION_V" -lt "$MIN_V" ]; then
    CHECK=0
  fi
  if [ -n "$MAX_V" ] && [ "$VERSION_V" -gt "$MAX_V" ]; then
    CHECK=0
  fi
  if [ "$CHECK" == "1" ]; then
    echo "Can compile $k"
    if [ -d "${DIR}/${BASE}.scptd" ]; then
      osacompile -l AppleScript -d -o "${DIR}/${BASE}.scptd/Contents/Resources/Scripts/main.scpt" "$k"
    else
      osacompile -l AppleScript -d -o "${DIR}/${BASE}.scpt" "$k"
    fi
  else
    echo "Can't compile $k : '$MIN' <= '$VERSION' <= '$MAX'   '$MIN_V' <= '$VERSION_V' <= '$MAX_V'"
  fi
  unset MIN
  unset MIN_V
  unset MAX
  unset MAX_V
fi
