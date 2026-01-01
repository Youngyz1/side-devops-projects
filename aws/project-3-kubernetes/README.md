### Step 1: Copy Your App from Project 2

```bash
# Copy your application files
cp ../project-2-cicd-pipeline/app.js .
cp ../project-2-cicd-pipeline/package.json .
cp ../project-2-cicd-pipeline/Dockerfile .
```

# Project 3: Kubernetes Container Orchestration
## **Project Overview**

### This project deploys a Node.js web application (`my-youngyzapp`) to an AWS EKS Kubernetes cluster, using Docker images stored in ECR, managed with `eksctl`. Horizontal Pod Autoscaler (HPA) is configured, and the application is exposed via a LoadBalancer service.

## **1. Prerequisites**

- AWS CLI configured with proper credentials.
- `eksctl` installed (v0.217.0 on Windows).
- `kubectl` installed.
- Docker installed and running locally.
- Node.js app ready with Dockerfile.

Bash::     minikube start
              minikube addons enable metrics-server
              eval $(minikube docker-env)

## **2. Docker Image Build & Push**

1. **Build Docker Image**

                           docker build -t my-youngyzapp:latest .

1. **Tag for ECR:**      aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com
                          docker tag my-youngyzapp:latest <account_id>.dkr.ecr.us-east-1.amazonaws.com/my-youngyzapp:latest

1. **Push to ECR:**    docker push <account_id>.dkr.ecr.us-east-1.amazonaws.com/my-youngyzapp:latest
****

**Result:** Image available in AWS ECR.

## 3. Deploying To Kubernetes

kubectl apply -f k8s/app.yaml
kubectl get pods
kubectl get services
kubectl get pods -w

### 4. Access Your Application

- Docker Desktop: Use EXTERNAL-IP from `kubectl get services`
- Minikube:      minikube service my-youngyzapp-service --url

## 5. Test Kubernetes Features

**Scaling:**

bash      

kubectl scale deployment my-youngyzapp --replicas=5
kubectl get pods -w
kubectl scale deployment my-youngyzapp --replicas=2

1. **Create Cluster:**   eksctl create cluster --name my-youngyzapp-cluster --region us-east-1 --nodes 2 --node-type t3.medium

<img width="1080" height="607" alt="image" src="https://github.com/user-attachments/assets/5fd72af1-4d6f-4f6b-abce-67b5dfbd0d3b" />

1. **Verify Node Group:**  eksctl get nodegroup --cluster my-youngyzapp-cluster --region us-east-1

4. Node IAM Role & ECR Access

- **Problem:** Nodes could not pull images from ECR (`ImagePullBackOff` / `ErrImagePull`).
- **Solution:** Attach AmazonEC2ContainerRegistryReadOnly policy to node IAM role.

Bash:      aws iam attach-role-policy \
--role-name <node-instance-role> \
--policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

- **Verify IAM Role from CloudFormation**

Bash:   aws cloudformation describe-stack-resources \
--stack-name eksctl-my-youngyzapp-cluster-nodegroup-<nodegroup> \
--query "StackResources[?ResourceType=='AWS::IAM::Role'].PhysicalResourceId" \
--output text

## **5. Kubernetes Deployment**

1. **Apply Deployment & Services:**   kubectl apply -f k8s/app.yaml
2. **Verify Deployment:**         kubectl rollout status deployment my-youngyzapp
kubectl get pods -o wide
kubectl get service my-youngyzapp-service

    **Result:** Deployment successful, pods running, LoadBalancer created.
curl http://<load-balancer-dns>

<img width="1080" height="607" alt="image" src="https://github.com/user-attachments/assets/c8a98923-aa19-436a-94cd-45a165aaf764" />

## **6. Horizontal Pod Autoscaler (HPA)**

1. **Verify HPA**

    bash:   kubectl get hpa

NAME                REFERENCE                  TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
my-youngyzapp-hpa   Deployment/my-youngyzapp   cpu: 1%/70%   2         10        2          105m

<img width="1080" height="607" alt="image" src="https://github.com/user-attachments/assets/346db8be-cac3-48a8-b0f8-3c0bf7368929" />

## 7. Troubleshooting

## **8. Cleanup**
