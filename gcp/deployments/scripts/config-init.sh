#!/bin/sh
apt-get update
apt-get install jq gettext -y
LOCAL_ESIGNET_PROPERTIES=deployments/configs/esignet.properties
UPDATED_ESIGNET_PROPERTIES=esignet-local.properties
export AUTHENTICATOR_SERVICE=MockAuthenticationService
export ESIGNET_HOST=$1
export API_INTERNAL=$1
export KEYCLOAK_URL=$1
export SOFTHSM_PIN=$(kubectl get secrets softhsm -n esignet -o jsonpath={.data.security-pin} | base64 --decode)
export KAFKA_URL=kafka-cluster-kafka-bootstrap.kafka:9092
export DB_HOST=$(gcloud sql instances describe $2 --format=json  | jq -r ".ipAddresses[0].ipAddress")
export DB_PORT=5432
export DB_USERNAME=postgres
export DB_PASSWORD=$(gcloud secrets versions access latest --secret $3)
export REDIS_HOST=$(gcloud redis instances describe $4 --region asia-south1 --format=json | jq -r ".host")
export API_PUBLIC_HOST=$1
export MISP_KEY=''
if [ $6 = "false" ]; then
  export AUTHENTICATOR_SERVICE=IdaAuthenticatorImpl
  export MISP_KEY=$misp_key
  export API_PUBLIC_HOST=api.collab.mosip.net
fi
envsubst < $LOCAL_ESIGNET_PROPERTIES  > $UPDATED_ESIGNET_PROPERTIES

kubectl create configmap esignet-local-properties -n esignet  --from-file=$UPDATED_ESIGNET_PROPERTIES


echo "esignet config map created"