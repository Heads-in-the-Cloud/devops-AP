#!/bin/bash

# Bash script used to remove all the containers that have exited.
docker rm $(docker ps --all -q -f status=exited)