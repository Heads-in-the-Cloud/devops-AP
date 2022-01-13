#!/bin/bash

# Global Variables
CLUSTER_NAME="ap-eks-cluster"
AWS_REGION="us-east-2"

NODE_TYPE="t2.micro"
NODE_COUNT=4
NODE_GROUP="linux-nodes"

# Cluster Check
if [ "$(eksctl get cluster --region $AWS_REGION | grep -q $CLUSTER_NAME ; echo $?)" == "0" ]; then
    echo Cluster was found, so no need to start a new one!
    exit
fi

eksctl create cluster \
--name $CLUSTER_NAME \
--region $AWS_REGION \
--nodegroup-name $NODE_GROUP \
--node-type $NODE_TYPE \
--nodes $NODE_COUNT

# Cluster Config
kubectl config set-context \
--current \
--namespace=nginx-ingress

# Changes the directory, but exits if it fails to find the folder
cd kubernetes-ingress/deployments/ || exit

kubectl apply -f common/ns-and-sa.yaml
kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml
kubectl apply -f common/ingress-class.yaml

kubectl apply -f rbac/rbac.yaml
kubectl apply -f deployment/nginx-ingress.yaml

kubectl apply -f service/loadbalancer-aws-elb.yaml

cd ../../

kubectl apply -f secrets.yml
kubectl apply -f deployments.yml
kubectl apply -f services.yml
kubectl apply -f ingress.yml

echo ""
echo "External DNS to access services:"
kubectl get service nginx-ingress -o go-template='{{range.status.loadBalancer.ingress}}{{.hostname}}{{end}}'