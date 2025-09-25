# Project Bedrock – Retail Store App on AWS EKS

This repository contains IaC scripts and Kubernetes manifests for deploying the **Retail Store Sample Application** (codenamed **Project Bedrock**) onto **Amazon Elastic Kubernetes Service (EKS)** using `eksctl`.

---

├── terraform/                   # Terraform infrastructure code
|   ├──.terraform/modules
|       ├──eks
|       ├── eks.kms
|       ├── vpc
|       ├── modules. json
│   ├── main.tf              # EKS + VPC core resources
│   ├── variables.tf         # Input variables (subnets, cluster name, region)
│   ├── outputs.tf           # Terraform outputs (cluster info, VPC ID, etc.)
│   ├── provider.tf          # AWS provider + backend config
|   ├── Iam.tf
|   ├── ACM.tf
|   ├──dynamodb.tf
|   ├── eks.tf
|   ├── rds.tf
│   └── vpc.tf               # VPC, subnets, IGW, route tables
│
├──k8s/                  # Kubernetes manifests
|   ├── DBS/          # App deployments & services
│   │   ├── Mysql-deployment.yaml
│   │   ├── Redis-deployment.yaml
│   │   ├── postgres-deployment.yaml
│   │   ├── rabbitmq-deployment.yaml
│   ├── deployments/          # App deployments & services
│   │   ├── carts.yaml
│   │   ├── orders.yaml
│   │   ├── ui.yaml
│   │   ├── inventory.yaml
|   ├── namespace.yaml       # Kubernetes namespace definition
├──ingress
│   ├── alb.ingress.yaml         # Ingress resource for ALB
├──services
│   ├──cart-svc.yaml
|   ├──catalog-svc.yaml
|   ├──orders-svc.yaml
|   ├──ui-svc.yaml
│   └── namespace.yaml
├──deployment.sh
├──.gitignore
├── GitHub/workflows
|    ├── terraform-deploy.yaml
├── iam_policy.json          # IAM policy for ALB controller
└── README.md                # Documentation (this file)

---
## 🚀 Features
- EKS Cluster provisioning with `eksctl`
- NodeGroup creation (scalable worker nodes)
- AWS Load Balancer Controller for ingress management
- Route 53 + ACM integration for custom domain & HTTPS
- Microservices deployed:
  - UI
  - Orders
  - Carts
  - Inventory

---

## 📦 Prerequisites

Ensure the following tools are installed and configured:

- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) (configured with `aws configure`)
- [eksctl](https://eksctl.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)
- A registered domain name in Route 53 (for HTTPS)

---

## ⚙️ Deployment Steps

### 1. Clone Repository
```bash
git clone https://github.com/Iziik/project-bedrock.git
cd project-bedrock
````

### 2. Create EKS Cluster with `eksctl`
Run ```./deployment.sh```

```bash
eksctl create cluster \
  --name bedrock-cluster \
  --region eu-west-2 \
  --nodegroup-name bedrock-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 4 \
  --managed
```

### 3. Enable IAM OIDC Provider

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster bedrock-cluster \
  --approve
```

### 4. Deploy AWS Load Balancer Controller

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master

eksctl create iamserviceaccount \
  --cluster bedrock-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name AWSLoadBalancerControllerRole \
  --attach-policy-arn arn:aws:iam::ACCOUNT-ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=bedrock-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```
REPLACE *ACCOUNT-ID* 

### 5. Deploy Application

```bash
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes-manifests.yaml
```

This deploys:

* Deployments (`orders`, `carts`, `inventory`, `ui`)
* Services (`ClusterIP` / `NodePort`)

### 6. Configure Route 53

1. Go to **Route 53 Console → Hosted Zones → YourDomain.com**
2. Create an **A Record (Alias)** pointing to your ALB DNS.
3. Use **AWS Certificate Manager (ACM)** to request a TLS certificate.
4. Attach certificate to ALB for HTTPS.

---

## 🧪 Verification

Check resources:

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
```

Test connectivity:

```bash
curl http://<ALB-DNS>
```

Check domain resolution:

```bash
dig yourdomain.com
nslookup yourdomain.com
```

Open the browser at:

```
https://yourdomain.com
```

---

## 👥 Developer Access (Read-Only)

Create IAM user with limited access:

```bash
aws iam create-user --user-name dev-readonly
aws iam attach-user-policy \
  --user-name dev-readonly \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSReadOnlyAccess
```

Provide credentials with:

```bash
aws iam create-access-key --user-name dev-readonly
```

Developers can then run:

```bash
aws eks update-kubeconfig --name bedrock-cluster --region eu-west-2
kubectl get pods -A
```

---

## 📖 Notes

* Default databases (MySQL, PostgreSQL, Redis, RabbitMQ) run **inside the cluster** for this phase.

---

✅ Your cluster and app should now be up and accessible!
