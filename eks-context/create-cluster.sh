#!/bin/bash
set -euo pipefail

source .env

export VPC_ID=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .VPC_ID)

export PUBLIC_SUBNET_1=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PUBLIC_SUBNET_IDS[0])
export PUBLIC_SUBNET_2=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PUBLIC_SUBNET_IDS[1])
export PUBLIC_SUBNET_3=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PUBLIC_SUBNET_IDS[2])

export PRIVATE_SUBNET_1=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PRIVATE_SUBNET_IDS[0])
export PRIVATE_SUBNET_2=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PRIVATE_SUBNET_IDS[1])
export PRIVATE_SUBNET_3=$(aws secretsmanager get-secret-value --secret-id prod/Angel/ResourceIDs | jq -r .SecretString | jq .PRIVATE_SUBNET_IDS[2])

export VPC_ID="${VPC_ID//\"}"
export PUBLIC_SUBNET_1="${PUBLIC_SUBNET_1//\"}"
export PUBLIC_SUBNET_2="${PUBLIC_SUBNET_2//\"}"
export PUBLIC_SUBNET_3="${PUBLIC_SUBNET_3//\"}"
export PRIVATE_SUBNET_1="${PUBLIC_SUBNET_1//\"}"
export PRIVATE_SUBNET_2="${PUBLIC_SUBNET_2//\"}"
export PRIVATE_SUBNET_3="${PUBLIC_SUBNET_3//\"}"

# # Cluster Check
if [ "$(eksctl get cluster --region $AWS_REGION | grep -q $CLUSTER_NAME ; echo $?)" == "0" ]; then
    echo Cluster was found, so no need to start a new one!
    exit
fi

envsubst < cluster.yml | eksctl create cluster --alb-ingress-access -f -

# Cluster Config
kubectl config set-context --current --namespace=$NAMESPACE

export USERS_IMAGE="$REPO_URL/$USERS_REPO:$USER_TAG"
export FLIGHTS_IMAGE="$REPO_URL/$FLIGHTS_REPO:$FLIGHTS_TAG"
export BOOKINGS_IMAGE="$REPO_URL/$BOOKINGS_REPO:$BOOKINGS_TAG"

kubectl apply -f namespace.yml
kubectl apply -f rbac-role.yml
envsubst < alb-ingress-controller.yml | kubectl apply -f -

kubectl apply -f secrets.yml
envsubst < deployments.yml | kubectl apply -f -
kubectl apply -f services.yml
envsubst < ingress.yml | kubectl apply -f -

LB_DNS="$(kubectl get ingress eks-ingress -o go-template='{{range.status.loadBalancer.ingress}}{{.hostname}}{{end}}')"

echo ""
echo "External DNS to access services: $LB_DNS"