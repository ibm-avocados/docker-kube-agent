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
if [[ $VERSION == *"openshift"* ]]; then
	wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.5/openshift-client-linux.tar.gz
	tar xvf openshift-client-linux.tar.gz
	ibmcloud oc cluster config --cluster $2
	./oc login -u apikey -p $1
	./oc new-project agent
	./oc new-build --strategy docker --binary --docker-image golang:latest --name agent
	git clone https://github.com/moficodes/kube-agent.git
	./oc start-build agent --from-dir . --follow
	./oc new-app agent/agent:latest
	./oc expose svc/agent
else
	kubectl create ns agent
  helm install agent kube-agent/kube-agent --set namespace=agent --set ingress.host=agent.$SUBDOMAIN --set ingress.secret=$SECRET --namespace=agent --set secret.jwtsecret=anystringbecausemofitoldmeto
fi
