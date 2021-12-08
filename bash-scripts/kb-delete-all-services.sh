#!/bin/bash

# Gets the length of a list
list_length () {
    echo $(wc -w <<< "$@")
}

# Shell script used to delete all the kubernetes services that are running
SERVICE_LIST=$(kubectl get services -o go-template='
    {{range .items}}
        {{.metadata.name}}
        {{"\n"}}
    {{end}}')

if [ $(list_length $SERVICE_LIST) -gt 0 ]; then
    for SERVICE in $SERVICE_LIST; do
        kubectl delete services $SERVICE
    done
else
    echo "No services are currently running!"
fi