#!/usr/bin/env bash
MY_PATH=$(dirname "$0")
STACK_NAME="AP-CF-Stack"

if [ "$(aws cloudformation describe-stacks --output text | grep -q $STACK_NAME ; echo $?)" == 0 ]; then
    echo "A stack with the same name exists so the program is going to exit."
    exit 1
fi

aws cloudformation deploy \
--template-file "$MY_PATH"/cloud-template.yml \
--stack-name $STACK_NAME \
--parameter-overrides file://"$MY_PATH"/secrets.json
