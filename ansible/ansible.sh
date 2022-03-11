#!/usr/bin/env bash
ansible_image="williamyeh/ansible:alpine3"
ansible_dir="./ansible-env"
working_dir="/ansible"

cat <<EOF > docker-compose.yaml
version: "3.9"

services:
  ansible:
    image: $ansible_image
    working_dir: $working_dir
    volumes:
      - $ansible_dir:$working_dir
    environment:
      - ANSIBLE_HOST_KEY_CHECKING=false
EOF

docker compose run ansible sh -c "
chmod 600 ./secrets/terraform.pem &&
ansible-playbook $*
"
rm docker-compose.yaml