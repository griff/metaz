#!/bin/bash

#  sign_applescript.bash
#  MetaZ
#
#  Created by Brian Olsen on 09/03/2020.
#
#set -o errexit
set -x

if [ "$CODE_SIGNING_ALLOWED" == "YES" ]; then
    counter=0
    while [ $counter -lt $SCRIPT_INPUT_FILE_COUNT ]
    do
        eval "export FILE=\$SCRIPT_INPUT_FILE_$counter"
        echo "Signing $FILE"
        xcrun codesign --force --sign - --preserve-metadata=identifier,entitlements "$FILE"
        ((counter++))
    done
fi
