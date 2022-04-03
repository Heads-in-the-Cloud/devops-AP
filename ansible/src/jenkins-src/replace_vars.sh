#!/usr/bin/env bash

# Program usage: replace_var <filename> <varnames> <varvalue>
if [ $# -lt 3 ]; then
    echo "Program usage: replace_var <filename> <varnames> <varvalue>"
fi

if [ ! -f "$1" ]; then
    echo "No file called $1 exists!"
    exit 1
else
    line_to_replace="$(cat $1 | grep -Po "$2=(.*)")"
    replaced_value="$2=$3"

    if [ "$line_to_replace" == "" ]; then
        echo "No variable found to replace."
        exit 1
    fi

    echo This operation will replace \( "$line_to_replace" \) with \( "$replaced_value" \).
    read -rep "Replace the line? (y/N): " answer

    if [ "${answer,,}" == "y" ]; then
        echo ""
        echo "Replacing the variable in the text."
        cat $1 | sed "s/"$line_to_replace"/"$replaced_value"/1"
        echo "Finished replacing the text!"
    else
        exit 0
    fi
fi