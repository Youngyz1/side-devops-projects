This document explains the full workflow used to deploy the **Project-1 Infrastructure** using **Terraform**, push changes to GitHub, and retrieve the **public IPv4** of an ECS Fargate task.

## **1. Clone the Repository**

Start by cloning your infrastructure repository:

1. git clone https://github.com/Osomudeya/side-devops-projects.git
2. git init
git add .
git commit -m "Initial commit for project 1 infrastructure"
git remote add origin https://github.com/Youngyz1/[side-devops-projects.git](https://github.com/Osomudeya/side-devops-projects.git)
git push -u origin main

## **2. Configure AWS CLI If Not Configured**

1. Ensure AWS credentials are configured:

           aws configure

1. Provide:
- AWS Access Key
- AWS Secret Key
- Region:

## **3. Review & Update Terraform Files**

Inside the project-1-infrastructure folder, the following important files were used:

1. [main.tf](http://main.tf/) – Defines ECS, IAM, Logs, Networking, and Fargate Service
2. [variables.tf](http://variables.tf/) – Inputs
3. [outputs.tf](http://outputs.tf/) – Helpful outputs such as cluster name and log group
4. You then updated [main.tf](http://main.tf/) to ensure that:

## **4. Initialize Terraform**

1. terraform init:   This downloads AWS provider plugins.

## **5. Validate & Apply the Infrastructure**

1. Check configuration: terraform validate
2. Preview everything: terraform plan
3. Deploy everything: terraform apply -auto-approve
4. Terraform created: ECS Cluster, ECS Task Definition, ECS Service, CloudWatch Log Group, IAM Execution Role, Security Group.
5. After apply, Terraform returned outputs such as: Cluster name, Service name, Log group name

## **6. Retrieve ECS Task ARN**

1. First, list tasks in your service: 

aws ecs list-tasks \
--cluster youngyz-devops-cluster \
--service-name youngyz-devops-cluster-youngyzapp-service \
--query "taskArns[0]" \
--output text

1. This returned something like: arn:aws:ecs:us-east-1:958421185668:task/youngyz-devops-cluster/40cc6f3d99104427adcbbcb3004438a0

## **7. Get Network Interface from ECS Task**

1. Each Fargate task has an ENI (Elastic Network Interface). Run: 

aws ecs describe-tasks \
--cluster youngyz-devops-cluster \
--tasks 40cc6f3d99104427adcbbcb3004438a0 \
--query "tasks[0].attachments[0].details"

1. The output contained:

networkInterface Id
privateIPv4Address
subnet Id

1. Example:

"name": "networkInterfaceId",
"value": "eni-04169cc5e48e01f92"

## **8. Retrieve the Public IPv4 Address**

1. Using the ENI: Run 

aws ec2 describe-network-interfaces \
--network-interface-ids eni-04169cc5e48e01f92 \
--query "NetworkInterfaces[0].Association.PublicIp" \
--output text

1. You received:

       **3.239.118.21**

This is the **public IP** of your container.

## **9. Test the Application in Browser**

1. [http://3.239.118.21](http://3.239.118.21/)

Your containerized app should be accessible publicly.

<img width="1080" height="607" alt="image" src="https://github.com/user-attachments/assets/1bc535fc-ee71-445b-8974-878daf8817cb" />

## **10. Destroy Resources**

1. Remove the entire infrastructure:

       terraform destroy -auto-approve

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/26366507-ebd9-40e2-8974-070ac23a5560" />
