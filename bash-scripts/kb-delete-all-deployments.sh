#!/bin/bash

# Gets the length of a list
list_length () {
    echo $(wc -w <<< "$@")
}

# Shell script used to delete all the kubernetes deployments that are running
DEPLOY_LIST=$(kubectl get deployments -o go-template='
    {{range .items}}
        {{.metadata.name}}
        {{"\n"}}
    {{end}}')

if [ $(list_length $DEPLOY_LIST) -gt 0 ]; then
    for DEPLOY in $DEPLOY_LIST; do
        kubectl delete deployments $DEPLOY
    done
else
    echo "No deployments are currently running!"
fi