#!/bin/bash
#set -euo pipefail

###############################################
# CONFIGURATION – CHANGE THESE VALUES
###############################################
CLUSTER_NAME="bedrock-cluster"
REGION="eu-west-2"
DOMAIN_NAME="project-june.xyz"     # Your app domain
HOSTED_ZONE_ID="Z012129536HLYEUD29TVS"           # Your Route 53 Hosted Zone ID
ACM_ARN=""                                # Will be auto-filled later

###############################################
# STEP 1: CREATE EKS CLUSTER
###############################################
#echo ">>> Creating EKS cluster: $CLUSTER_NAME ..."
#eksctl create cluster \
 # --name $CLUSTER_NAME \
  #--region $REGION \
  #--with-oidc \
  #--managed \
#  --nodes 3

#aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

###############################################
# STEP 2: INSTALL AWS LOAD BALANCER CONTROLLER
###############################################
#echo ">>> Installing AWS Load Balancer Controller ..."

#VPC_ID=$(aws eks describe-cluster \
#  --name $CLUSTER_NAME \
#  --region $REGION \
#  --query "cluster.resourcesVpcConfig.vpcId" \
#  --output text)

#helm repo add eks https://aws.github.io/eks-charts
#helm repo update

#helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
#  -n kube-system \
#  --set clusterName=$CLUSTER_NAME \
#  --set serviceAccount.create=false \
#  --set serviceAccount.name=aws-load-balancer-controller \
#  --set region=$REGION \
#  --set vpcId=$VPC_ID

###############################################
# STEP 3: REQUEST ACM CERTIFICATE
###############################################
#echo ">>> Requesting ACM certificate for $DOMAIN_NAME ..."

#ACM_ARN=$(aws acm request-certificate \
#  --domain-name $DOMAIN_NAME \
#  --validation-method DNS \
#  --region $REGION \
#  --query CertificateArn \
#  --output text)

#echo "ACM Certificate ARN: $ACM_ARN"

# Get CNAME validation record
#RECORD_NAME=$(aws acm describe-certificate --certificate-arn $ACM_ARN --region $REGION \
#  --query "Certificate.DomainValidationOptions[0].ResourceRecord.Name" --output text)

#RECORD_VALUE=$(aws acm describe-certificate --certificate-arn $ACM_ARN --region $REGION \
#  --query "Certificate.DomainValidationOptions[0].ResourceRecord.Value" --output text)

# Insert validation record into Route53
#aws route53 change-resource-record-sets \
#  --hosted-zone-id $HOSTED_ZONE_ID \
#  --change-batch "{
#    \"Changes\": [{
#      \"Action\": \"UPSERT\",
#      \"ResourceRecordSet\": {
#        \"Name\": \"$RECORD_NAME\",
#        \"Type\": \"CNAME\",
#        \"TTL\": 300,
#        \"ResourceRecords\": [{\"Value\": \"$RECORD_VALUE\"}]
 #     }
#    }]
#  }"

#echo ">>> Waiting for ACM certificate validation ..."
#aws acm wait certificate-validated --certificate-arn $ACM_ARN --region $REGION
#echo "Certificate validated successfully."

###############################################
# STEP 4: DEPLOY APPLICATION (from repo manifests)
###############################################
#echo ">>> Deploying Retail Store Sample App ..."

kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml

###############################################
# STEP 5: CREATE INGRESS WITH ALB + ACM + ROUTE53
###############################################
echo ">>> Creating Ingress for ALB ..."
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: retail-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: $ACM_ARN
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}, {"HTTP":80}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  ingressClassName: alb
  rules:
  - host: $DOMAIN_NAME
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ui
            port:
              number: 80
EOF

###############################################
# DONE
###############################################
echo ">>> Deployment complete!"
echo "Access your app at: https://$DOMAIN_NAME"
