# ==============================
# Configuration - Update these
# ==============================
$ClusterName = "youngyzapp-cicd-cluster"
$ServiceName = "youngyzapp-cicd-service"
$ECRRepository = "my-youngyzapp"
$LogGroupName = "/ecs/youngyzapp-cicd-task"
$ExecutionRoleName = "ecsTaskExecutionRole-$ClusterName" # Optional

# ==============================
# 1️⃣ Scale ECS service to 0
# ==============================
Write-Host "Scaling down ECS service..."
aws ecs update-service --cluster $ClusterName --service $ServiceName --desired-count 0

# ==============================
# 2️⃣ Delete ECS service
# ==============================
Write-Host "Deleting ECS service..."
aws ecs delete-service --cluster $ClusterName --service $ServiceName --force

# ==============================
# 3️⃣ Delete ECS cluster
# ==============================
Write-Host "Deleting ECS cluster..."
aws ecs delete-cluster --cluster $ClusterName

# ==============================
# 4️⃣ Delete ECR repository
# ==============================
Write-Host "Deleting ECR repository..."
aws ecr delete-repository --repository-name $ECRRepository --force

# ==============================
# 5️⃣ Delete CloudWatch log group
# ==============================
Write-Host "Deleting CloudWatch log group..."
aws logs delete-log-group --log-group-name $LogGroupName

# ==============================
# 6️⃣ Delete ECS ENIs
# ==============================
Write-Host "Deleting ENIs associated with ECS tasks..."
$ENIs = aws ec2 describe-network-interfaces --filters @{Name="description";Values="*ECS*"} --query "NetworkInterfaces[].NetworkInterfaceId" --output text
if ($ENIs) {
    foreach ($eni in $ENIs -split "\t") {
        Write-Host "Deleting ENI: $eni"
        aws ec2 delete-network-interface --network-interface-id $eni
    }
} else {
    Write-Host "No ECS ENIs found."
}

# ==============================
# 7️⃣ Optional: Delete ECS execution role
# ==============================
Write-Host "Deleting ECS execution IAM role (optional)..."
aws iam delete-role --role-name $ExecutionRoleName

Write-Host "✅ Cleanup complete!"
