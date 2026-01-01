## **Project Overview**

Project 2 is a Node.js application deployed on **AWS ECS Fargate** using a CI/CD pipeline configured with **GitHub Actions**. This documentation details the setup, deployment, and cleanup process for the project.

## **1. GitHub Actions Workflow**

The workflow automates testing, Docker image building, pushing to **ECR**, and deployment to ECS.

.github/workflows/deploy.yml

```
name: Deploy Project 2 to AWS ECS

on:
  push:
    branches:
      - main
    paths:
      - aws/project-2-cicd-pipeline/**
  pull_request:
    branches:
      - main
    paths:
      - aws/project-2-cicd-pipeline/**
  workflow_dispatch:

env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  ECR_REPOSITORY: ${{ secrets.ECR_REPOSITORY }}
  ECS_SERVICE: ${{ secrets.ECS_SERVICE }}
  ECS_CLUSTER: ${{ secrets.ECS_CLUSTER }}
  ECS_TASK_DEFINITION: ${{ secrets.ECS_TASK_DEFINITION }}

jobs:
  test:
    name: Test Application
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: aws/project-2-cicd-pipeline

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 18
          cache: 'npm'
          cache-dependency-path: aws/project-2-cicd-pipeline/package-lock.json

```

### **2. Workflow Triggers**

`push` to `main` branch

`pull_request` to `main`

`workflow_dispatch` (manual trigger

## **3. Environment Variables**

Configured via GitHub Secrets:

- `AWS_REGION`
- `ECR_REPOSITORY`
- `ECS_SERVICE`
- `ECS_CLUSTER`
- `ECS_TASK_DEFINITION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## **4. Workflow Jobs**

**1 Test Application**

**2 Deploy to AWS ECS**

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/4845ca69-62c9-45fb-a8a6-b01a87de59fd" />

## **5. Fetching Public IP of ECS Task**

**List ECS tasks**

aws ecs list-tasks --cluster youngyzapp-cicd-cluster --service-name youngyzapp-cicd-service --query "taskArns[0]" --output text

**Describe ECS task to get ENI**

aws ecs describe-tasks --cluster youngyzapp-cicd-cluster --tasks <TASK_ARN> --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text

**Get public IP from ENI**

aws ec2 describe-network-interfaces --network-interface-ids <ENI_ID> --query 'NetworkInterfaces[0].Association.PublicIp' --output text

**Example Output:**

TASK_ARN: arn:aws:ecs:us-east-1:123456789012:task/youngyzapp-cicd-cluster/abcdef123456
ENI_ID: eni-049c3a959def701b1
PUBLIC_IP: 3.123.45.67

**Access the webapp On Port 3001**
 http://44.200.27.230:3001/

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/1dffcf1f-2f09-44e9-a73a-3e1874e4bca2" />

## 6. Cleanup (Destroying Resources)

Manual Cleanup Commands

**Scale ECS service to 0**

aws ecs update-service --cluster youngyzapp-cicd-cluster --service youngyzapp-cicd-service --desired-count 0

**Delete ECS service**

aws ecs delete-service --cluster youngyzapp-cicd-cluster --service youngyzapp-cicd-service --force

**Delete ECS cluster**

aws ecs delete-cluster --cluster youngyzapp-cicd-cluster

**Delete ECR repository**

aws ecr delete-repository --repository-name my-youngyzapp --force

**Delete CloudWatch logs**

aws logs delete-log-group --log-group-name /ecs/youngyzapp-cicd-task

**Delete IAM role (optional)**

aws iam delete-role --role-name ecsTaskExecutionRole-youngyzapp-cicd-cluster

### **Automated Cleanup Script**

- Created `Cleanup-AWS.ps1` to remove ECS services, clusters, ECR repositories, ENIs, CloudWatch log groups, and IAM roles.
- Verified cleanup using `Check-AwsCleanup.ps1`.

**Note:** Some resources may appear in script output due to AWS eventual consistency but are actually deleted when checked in the AWS Console.

## **7. Observations / Notes**

- CloudWatch logs are **not automatically created** unless task definitions explicitly enable logging.
- IAM roles must have all policies detached before deletion.
- ECS and ECR deletions propagate eventually; PowerShell scripts may report resources briefly after deletion.
- Public IP is fetched using the ENI associated with ECS tasks.

## **8. Lessons Learned**

- GitHub Actions workflows can fully automate ECS deployment.
- AWS ECS requires explicit CloudWatch logging configuration.
- Cleaning up AWS resources requires handling dependencies (IAM roles, ENIs, log groups).
- Eventual consistency in AWS may cause temporary discrepancies in resource checks.

This documentation gives me a **complete reference** of what i did, including deployment, testing, fetching the app IP, and cleanup.
