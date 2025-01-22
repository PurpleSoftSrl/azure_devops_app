#!/usr/bin/env bash

exec > "${SRCROOT}/prebuild.log" 2>&1

echo "start pre action script"
echo "SRCROOT: ${SRCROOT}"
echo "CONFIGURATION: ${CONFIGURATION}"

function entry_decode() { echo "${*}" | base64 --decode; }

IFS=',' read -r -a define_items <<< "$DART_DEFINES"

for index in "${!define_items[@]}"
do
    decodedEntry=$(entry_decode "${define_items[$index]}");

    if [[ $decodedEntry != *"flutter"* ]];
      then define_items["$index"]=$decodedEntry;
    fi
    
done

printf "%s\n" "${define_items[@]}" > "${SRCROOT}/Flutter/Environment${CONFIGURATION}.xcconfig"
