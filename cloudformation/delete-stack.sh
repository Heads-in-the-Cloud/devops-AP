#!/usr/bin/env bash
STACK_NAME="AP-CF-Stack"

if [ "$(aws cloudformation describe-stacks --output text | grep -q $STACK_NAME ; echo $?)" == 1 ]; then
    echo "The stack does not exist so the program is going to exit."
    exit 1
fi

aws cloudformation delete-stack \
--stack-name $STACK_NAME

echo "Stack deletion started."