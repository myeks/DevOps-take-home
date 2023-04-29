
# Define variables
variable "aws_region" {
  default = "us-west-2"
}

variable "github_repo_owner" {
  default = "regovtech"
}

variable "github_repo_name" {
  default = "your-repo-name"
}

variable "github_oauth_token" {
  default = "your-oauth-token"
}

variable "ecr_registry_id" {
  default = "176350447910"
}

variable "s3_bucket_name" {
  default = "your-s3-bucket-name"
}

variable "iam_role_name" {
  default = "your-iam-role-name"
}

# Create IAM role for Fargate
resource "aws_iam_role" "fargate_task_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create IAM policy for S3 bucket access
resource "aws_iam_policy" "s3_policy" {
  name_prefix = "s3-policy-"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      }
    ]
  })
}

# Attach S3 policy to the IAM role
resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.fargate_task_role.name
}

# Create ECR repository
resource "aws_ecr_repository" "my_repository" {
  name = "my-repo-name"
}

# Create CloudWatch Events rule to trigger Fargate task
resource "aws_cloudwatch_event_rule" "my_rule" {
  name        = "my-rule"
  description = "Triggers Fargate task when a file is uploaded to S3"
  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail_type = ["AWS API Call via CloudTrail"]
    detail      = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["PutObject"]
      requestParameters = {
        bucketName = [var.s3_bucket_name]
      }
    }
  })
}

# Create target for CloudWatch Events rule
resource "aws_cloudwatch_event_target" "my_target" {
  rule = aws_cloudwatch_event_rule.my_rule.name

  arn = aws_ecs_task_definition.my_task_definition.arn
}

# Create Fargate task definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family = "my-task-definition"

  container_definitions = jsonencode([
    {
      name      = "my-container"
      image     = "${var.ecr_registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com/my-repo-name:${var.image_tag}"
      essential = true
      environment = [
        {
          name  = "S3_BUCKET"
          value = var.s3_bucket_name
        }
      ]
      secrets = [
        {
          name      = "GITHUB_OAUTH_TOKEN"
          valueFrom = data.aws_ssm_parameter.github_oauth_token.

}
]
}
