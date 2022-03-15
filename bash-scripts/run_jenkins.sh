#!/bin/bash
docker run \
    --name jenkins \
    --rm \
     -p 8090:8080 \
     -p 50000:50000 \
     -v jenkins_data:/var/jenkins_home \
    jenkins/jenkins:lts