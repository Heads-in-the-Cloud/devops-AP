#!/usr/bin/env bash

if [ $# -lt 3 ]; then
    echo "Usage: $0 keyArn inputFile outputDir"
    exit 1
fi

keyArn=$1
inputFile=$2
outputDir=$3

/usr/local/bin/aws-encryption-cli --encrypt \
--input $inputFile \
--wrapping-keys key=$keyArn \
--metadata-output ~/metadata \
--encryption-context purpose=test \
--commitment-policy require-encrypt-require-decrypt \
--output $outputDir