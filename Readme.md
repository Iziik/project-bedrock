# Project Bedrock – Retail Store App on AWS EKS

This repository contains IaC scripts and Kubernetes manifests for deploying the **Retail Store Sample Application** (codenamed **Project Bedrock**) onto **Amazon Elastic Kubernetes Service (EKS)** using `eksctl`.

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
git clone https://github.com/<your-repo>/project-bedrock.git
cd project-bedrock
````

### 2. Create EKS Cluster with `eksctl`

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
  --attach-policy-arn arn:aws:iam::<YOUR_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=bedrock-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 5. Deploy Application

```bash
kubectl apply -f k8s/
```

This deploys:

* Deployments (`orders`, `carts`, `inventory`, `ui`)
* Services (`ClusterIP` / `NodePort`)
* Ingress (via ALB)

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
