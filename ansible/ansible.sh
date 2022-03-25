#!/usr/bin/env bash
source .env

cat <<EOF > dockerfile
FROM williamyeh/ansible:alpine3
RUN sudo apk update
RUN apk add python3
RUN apk add py3-pip
RUN pip install boto
RUN pip install boto3
EOF

docker context use default
docker build -t asoto22/ansible:latest .
rm dockerfile

cat <<EOF > docker-compose.yaml
version: "3.9"

services:
  ansible:
    image: asoto22/ansible:latest
    working_dir: $working_dir
    volumes:
      - $ansible_dir:$working_dir
    environment:
      - ANSIBLE_HOST_KEY_CHECKING=false
      - AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
      - AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
      - AWS_REGION=$AWS_REGION
EOF

docker compose run ansible sh -c "
chmod 600 ./secrets/terraform.pem &&
ansible-playbook $*
"
rm docker-compose.yaml
docker rm "$(docker ps --all -q -f status=exited)"