#!/usr/bin/env bash

AWS_REGION="us-east-2"
AWS_USER_ID="902316339693"

aws ecr get-login-password --region ${AWS_REGION} |\
docker login \
--username AWS \
--password-stdin ${AWS_USER_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com