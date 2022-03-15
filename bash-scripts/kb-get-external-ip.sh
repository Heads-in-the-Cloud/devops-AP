#!/usr/bin/env bash

# Bash script used to get the port numbers of all the NodePort services running
kubectl get service nginx-ingress -o go-template='{{range.status.loadBalancer.ingress}}{{.hostname}}{{end}}'