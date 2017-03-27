#!/bin/bash
set -e

export SECRET_NAME="ssl-secret"
export IMAGE_TAG="${CI_COMMIT_ID}"
export IMAGE_NAME="nginx"
export APPLICATION_NAME="nginx"

# authenticate to google cloud
codeship_google authenticate

# set compute zone ${CLUSTER_ZONE}
gcloud config set compute/zone us-central1-b

# set kubernetes cluster
gcloud container clusters get-credentials "${CLUSTER_NAME}"

# install envsubst
apt-get install gettext-base -y

# update kubernetes Deployment file
envsubst < deploy/kubernetes/nginx_deployment.yml.template > deploy/kubernetes/nginx_deployment.yml
envsubst < deploy/kubernetes/secrets.yml.template > deploy/kubernetes/secrets.yml

cat deploy/kubernetes/nginx_deployment.yml

# deploy
deployment_flag=$(GOOGLE_APPLICATION_CREDENTIALS=/keyconfig.json kubectl get deployment -l app=${APPLICATION_NAME})

if [[ -z "$deployment_flag" ]]; then
  echo "Create new deployment and service for ${APPLICATION_NAME}"
  GOOGLE_APPLICATION_CREDENTIALS=/keyconfig.json kubectl create -f deploy/kubernetes/secrets.yml
  GOOGLE_APPLICATION_CREDENTIALS=/keyconfig.json kubectl create -f deploy/kubernetes/nginx_deployment.yml
  GOOGLE_APPLICATION_CREDENTIALS=/keyconfig.json kubectl expose deployment ${APPLICATION_NAME} --name=${APPLICATION_NAME} --port=80,443 --type="LoadBalancer"
else
  echo "Rolling update for ${APPLICATION_NAME}"
  GOOGLE_APPLICATION_CREDENTIALS=/keyconfig.json kubectl apply -f deploy/kubernetes/nginx_deployment.yml
fi
