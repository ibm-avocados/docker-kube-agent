#!/bin/bash

ibmcloud plugin install -f kubernetes-service
sleep 20
ibmcloud login --apikey $1 -r "us-south"
sleep 20
ibmcloud ks cluster config --cluster $2
sleep 10
dnf install -y openssl
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm repo add kube-agent https://moficodes.github.io/kube-agent-helm/
sleep 10
SUBDOMAIN=`ibmcloud ks cluster get --cluster "$2" | grep Subdomain | awk '{ print $NF }'`
SECRET=`ibmcloud ks cluster get --cluster "$2" | grep Secret | awk '{ print $NF }'`
sleep 10
kubectl create ns agent
helm install agent kube-agent/kube-agent --set namespace=agent --set ingress.host=agent.$SUBDOMAIN --set ingress.secret=$SECRET --namespace=agent --set secret.jwtsecret=anystringbecausemofitoldmeto
