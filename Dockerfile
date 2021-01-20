FROM fedora:latest

RUN dnf upgrade -y
RUN dnf install -y \
    wget \
    unzip 

RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
chmod +x ./kubectl && \
mv ./kubectl /usr/local/bin/kubectl && \
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash 


RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh && \
ibmcloud config --check-version=false

WORKDIR /
RUN mkdir /scripts
COPY scripts/run.sh /scripts/run.sh

ENTRYPOINT ["/scripts/run.sh"]
