#!/bin/bash

ibmcloud plugin install -f kubernetes-service
sleep 20
ibmcloud login --apikey $1 -r "us-south"
sleep 20
ibmcloud ks cluster config --cluster $2
SUBDOMAIN=`ibmcloud ks cluster get --cluster "$2" | grep Subdomain | awk '{ print $NF }'`
SECRET=`ibmcloud ks cluster get --cluster "$2" | grep Secret | awk '{ print $NF }'`
VERSION=`ibmcloud ks cluster get --cluster "$2" | grep Version | awk '{ print $NF }'`
sleep 10
if [[ $VERSION == *"openshift"* ]]; then
	wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.5/openshift-client-linux.tar.gz
	tar xvf openshift-client-linux.tar.gz
	ibmcloud oc cluster config --cluster $2
	./oc login -u apikey -p $1
	./oc new-project agent
	./oc new-build --strategy docker --binary --docker-image golang:latest --name agent
	git clone https://github.com/moficodes/kube-agent.git
	cd kube-agent/
	../oc start-build agent --from-dir . --follow
	cd ../
	./oc new-app agent/agent:latest
	./oc expose svc/agent
else
	kubectl create ns agent
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  helm repo add kube-agent https://moficodes.github.io/kube-agent-helm/
  helm install agent kube-agent/kube-agent --set namespace=agent --set ingress.host=agent.$SUBDOMAIN --set ingress.secret=$SECRET --namespace=agent --set secret.jwtsecret=anystringbecausemofitoldmeto
fi
