#!/bin/bash

# Global Variables
CLUSTER_NAME="ap-eks-cluster"
AWS_REGION="us-east-2"

# Cluster Check
if [ "$(eksctl get cluster --region $AWS_REGION | grep -q $CLUSTER_NAME ; echo $?)" == "1" ]; then
    echo No cluster was found, so cannot delete anything.
    exit
fi

eksctl delete cluster \
--name $CLUSTER_NAME \
--region $AWS_REGION