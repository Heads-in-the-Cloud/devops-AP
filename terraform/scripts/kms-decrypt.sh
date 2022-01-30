#!/usr/bin/env bash

if [ $# -lt 3 ]; then
    echo "Usage: $0 keyArn inputFile outputDir"
    exit 1
fi

keyArn=$1
inputFile=$2
outputDir=$3

aws-encryption-cli --decrypt \
--input $inputFile \
--wrapping-keys key=$keyArn \
--commitment-policy require-encrypt-require-decrypt \
--encryption-context purpose=test \
--metadata-output ~/metadata \
--max-encrypted-data-keys 1 \
--buffer \
--output $outputDir