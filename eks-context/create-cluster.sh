#!/bin/bash

# Global Variables
export CLUSTER_NAME="ap-eks-cluster"
export AWS_REGION="us-east-2"

export NODE_TYPE="t2.micro"
export NODE_COUNT=4
export NODE_GROUP="eks-nodes"

export VPC_ID=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .VPC_ID)

export PUBLIC_SUBNET_1=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PUBLIC_SUBNET_IDS[0])
export PUBLIC_SUBNET_2=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PUBLIC_SUBNET_IDS[1])
export PUBLIC_SUBNET_3=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PUBLIC_SUBNET_IDS[2])

export PRIVATE_SUBNET_1=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PRIVATE_SUBNET_IDS[0])
export PRIVATE_SUBNET_2=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PRIVATE_SUBNET_IDS[1])
export PRIVATE_SUBNET_3=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PRIVATE_SUBNET_IDS[2])

# Cluster Check
if [ "$(eksctl get cluster --region $AWS_REGION | grep -q $CLUSTER_NAME ; echo $?)" == "0" ]; then
    echo Cluster was found, so no need to start a new one!
    exit
fi

envsubst < cluster.yml | eksctl create cluster -f -
# --nodegroup-name $NODE_GROUP \
# --node-type $NODE_TYPE \
# --nodes $NODE_COUNT

# Cluster Config
kubectl config set-context --current --namespace=nginx-ingress

kubectl apply -f nginx_ingress/ns-and-sa.yaml
kubectl apply -f nginx_ingress/default-server-secret.yaml
kubectl apply -f nginx_ingress/nginx-config.yaml
kubectl apply -f nginx_ingress/ingress-class.yaml
kubectl apply -f nginx_ingress/rbac.yaml
kubectl apply -f nginx_ingress/nginx-ingress.yaml
kubectl apply -f nginx_ingress/loadbalancer-aws-elb.yaml
kubectl apply -f secrets.yml
kubectl apply -f deployments.yml
kubectl apply -f services.yml
kubectl apply -f ingress.yml

echo ""
echo "External DNS to access services:"
kubectl get service nginx-ingress -o go-template='{{range.status.loadBalancer.ingress}}{{.hostname}}{{end}}'