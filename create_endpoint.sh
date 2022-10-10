#!/bin/bash

#####################################
# Author: Carles Cortes Costa
# Version: v1.0.0
# Date: 06-10-2022
# Description: Script to create an Endpoint for the EdgeCoreServices Team
# Usage: ./create_endpoint.sh
#####################################

set -e # Exits if any command fails

set -x # Prints commands with the variables expanded

# Abstract the help as a function, so it does not clutter the script.
print_help() {
  echo "Usage: $0 [flags] <arguments>"
  echo "Flags:"
  echo "-h for help."
  echo "$0 <ENVIRONMENT_URL> <ORIGIN_ACCOUNT> <CUSTOMER_ENVIRONMENT> <CLUSTER_ID> <SQS_DESTINATION> <RANCHER_INSTANCE> <VAULT_TOKEN>"
}

# Parse the flags.
optstring=":hd"
while getopts ${optstring} options; do
  case ${options} in
    h)
      print_help
      exit 0 # Stop script, but consider it a success.
      ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;; 
  esac
done


#Define the variables as positional arguments in BASH
ENVIRONMENT_URL=${1}
ORIGIN_ACCOUNT=${2}
CUSTOMER_ENVIRONMENT=${3}
CLUSTER_ID=${4}
SQS_DESTINATION=${5}
RANCHER_INSTANCE=${6}
VAULT_TOKEN=${7}
SUBJECT_FILTER=lni_${CUSTOMER_ENVIRONMENT}_edge_${ORIGIN_ACCOUNT}
VAULT_NAMESPACE=edgecoreservices
VAULT_ADDR=https://vault.prod.lni.navify.com/
KUBERNETES_ENDPOINT=https://rvap.${RANCHER_INSTANCE}.anywhere.navify.com/k8s/clusters/${CLUSTER_ID}
KUBERNETES_SA_ACCOUNT=team-core-services-cc
KUBERNETES_NAMESPACE=team-core-services-cc

#Ensure the right number of arguments are passed
if [[ ${#*} -ne 7 ]]; then
  echo "Incorrect number of arguments!"
  echo "Usage: $0 <argument1>..."
  exit 1
fi

#Chek the input lenght using parameter expansion.
if [[ ${#ORIGIN_ACCOUNT} -ne 12 ]]; then
  echo "AWS Account are 12 digits, please check your input for ORIGIN_ACCOUNT"
  exit 2
fi

### Create the Endpoint, will stop script if fails
curl -X PUT -S --location "https://iot-api.${ENVIRONMENT_URL}.edge-services.navify.com/endpoint" -H "Content-Type: application/json" -d "{ \"thingName\": \"${ORIGIN_ACCOUNT}:${CUSTOMER_ENVIRONMENT}:${CLUSTER_ID}\"}" -o $CLUSTER_ID.endpoint

cat $CLUSTER_ID.endpoint | jq -r .PrivateKey > $CLUSTER_ID.key
cat $CLUSTER_ID.endpoint | jq -r .certificatePem > $CLUSTER_ID.crt

# Configure routing to send messages to SQS Queue
curl -X PUT -S --location "https://iot-api.${ENVIRONMENT_URL}.edge-services.navify.com/rule/tosqs" -H "Content-Type: application/json"  -d "{\"thingName\": \"${ORIGIN_ACCOUNT}:${CUSTOMER_ENVIRONMENT}:${CLUSTER_ID}\", \"topicFilter\": \"${SUBJECT_FILTER}\", \"sqsQueueUrl\": \"${SQS_DESTINATION}\" }"

###VAULT PART

# Vault login
export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=${VAULT_ADDR}
export VAULT_NAMESPACE=${VAULT_NAMESPACE}
vault login ${VAULT_TOKEN}

# Create Entries for Certificate
vault kv put edge-secrets/clusters/$CLUSTER_ID key=@$CLUSTER_ID.key crt=@$CLUSTER_ID.crt

# Now we create a policy that will allow the k8s Cluster to read and create entries in the value store
cat > my_policy.hcl <<EOF 
path "edge-secrets/data/clusters/$CLUSTER_ID" {
  capabilities = [ "read" ]
}
EOF

vault policy write ${CLUSTER_ID}_read_cert my_policy.hcl

# Give Permissions to the kubernetes cluster to connect to vault:
echo -n | openssl s_client -connect rvap.$RANCHER_INSTANCE.anywhere.navify.com:443 | openssl x509 > my-kubernetes-api-endpoint-ca.crt
vault auth enable --path=kubernetes/$CLUSTER_ID kubernetes
vault write auth/kubernetes/$CLUSTER_ID/config kubernetes_host=$KUBERNETES_ENDPOINT disable_local_ca_jwt=true disable_iss_validation=true kubernetes_ca_cert=@my-kubernetes-api-endpoint-ca.crt

# Finally we assign the policy created
vault write auth/kubernetes/$CLUSTER_ID/role/${CLUSTER_ID}_cert_read bound_service_account_names="${KUBERNETES_SA_ACCOUNT}" bound_service_account_namespaces="${KUBERNETES_NAMESPACE}" policies=${CLUSTER_ID}_read_cert ttl=604800
