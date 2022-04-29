#!/usr/bin/env bash
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id/)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)
MY_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4/)

ZONE_TAG="Z0335660TF3AY4ZQWQ77"
NAME_TAG=$(aws ec2 describe-tags --region ${AZ::-1} --filters "Name=resource-id,Values=${INSTANCE_ID}" --query 'Tags[?Key==`AUTO_DNS_NAME`].Value' --output text)

aws route53 change-resource-record-sets \
--hosted-zone-id $ZONE_TAG \
--change-batch '{"Changes": [{"Action": "UPSERT","ResourceRecordSet": {"Name": "'$NAME_TAG'","Type": "A","TTL": 300,"ResourceRecords": [{ "Value": "'$MY_IP'" }]}}]}'