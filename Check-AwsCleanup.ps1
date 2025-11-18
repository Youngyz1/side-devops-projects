# -----------------------------
# Check-AwsCleanup.ps1
# -----------------------------
Write-Host "Checking AWS resources cleanup status..." -ForegroundColor Cyan

# Set your cluster, service, and repo names
$clusterName = "youngyzapp-cicd-cluster"
$serviceName = "youngyzapp-cicd-service"
$repoName    = "my-youngyzapp"
$logGroup    = "/ecs/youngyzapp-cicd-task"
$iamRoleName = "ecsTaskExecutionRole-$clusterName"

# 1️⃣ Check ECS Cluster
$clusters = aws ecs list-clusters --query "clusterArns" --output text
if ($clusters -notmatch $clusterName) {
    Write-Host "✅ ECS cluster deleted"
} else {
    Write-Host "⚠️ ECS cluster still exists"
}

# 2️⃣ Check ECS Service
$services = aws ecs list-services --cluster $clusterName --query "serviceArns" --output text
if ($services -notmatch $serviceName) {
    Write-Host "✅ ECS service deleted"
} else {
    Write-Host "⚠️ ECS service still exists"
}

# 3️⃣ Check ECS Tasks
$tasks = aws ecs list-tasks --cluster $clusterName --query "taskArns" --output text
if ([string]::IsNullOrEmpty($tasks)) {
    Write-Host "✅ No ECS tasks found"
} else {
    Write-Host "⚠️ ECS tasks still exist"
}

# 4️⃣ Check ECR Repository
$repos = aws ecr describe-repositories --query "repositories[*].repositoryName" --output text
if ($repos -notmatch $repoName) {
    Write-Host "✅ ECR repository deleted"
} else {
    Write-Host "⚠️ ECR repository still exists"
}

# 5️⃣ Check CloudWatch Log Group
$logGroups = aws logs describe-log-groups --query "logGroups[*].logGroupName" --output text
if ($logGroups -notmatch $logGroup) {
    Write-Host "✅ CloudWatch log group deleted"
} else {
    Write-Host "⚠️ CloudWatch log group still exists"
}

# 6️⃣ Check IAM Role
$role = aws iam get-role --role-name $iamRoleName --query "Role.RoleName" --output text 2>$null
if ($role -eq $null) {
    Write-Host "✅ IAM role deleted"
} else {
    Write-Host "⚠️ IAM role still exists"
}

# 7️⃣ Check ENIs
$enis = aws ec2 describe-network-interfaces --query "NetworkInterfaces[*].NetworkInterfaceId" --output text
if ([string]::IsNullOrEmpty($enis)) {
    Write-Host "✅ No leftover ENIs"
} else {
    Write-Host "⚠️ Some ENIs still exist: $enis"
}

Write-Host "`n✅ Cleanup check complete!" -ForegroundColor Green
