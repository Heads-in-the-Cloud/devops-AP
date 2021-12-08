#!/bin/bash

# Bash script used to get the port numbers of all the NodePort services running
kubectl get svc -o go-template='
{{- range .items -}}
	{{- $node_name := .metadata.name -}}
	{{- range.spec.ports -}}
		{{- if .nodePort -}}
			{{$node_name}}{{" : "}}{{.nodePort}}{{"\n"}}
		{{- end -}}
	{{- end -}}
{{- end -}}'