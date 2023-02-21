#!/bin/bash
minikube start --driver docker --alsologtostderr

kubectl create ns vault
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault \
    --namespace vault --set server.dev.enabled='true' \
    --set server.dev.devRootToken='root'

minikube service vault -n vault