#################################################################################################
# This file describes the IAM resources
#################################################################################################
#################################################################################################
#ECS task role
#################################################################################################
resource "aws_iam_role" "ecsTaskExecutionRole" {
    name                  = "ecsTaskExecutionRole"
    assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions               = ["sts:AssumeRole"]

    principals {
      type                = "Service"
      identifiers         = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
    role                  = aws_iam_role.ecsTaskExecutionRole.name
    policy_arn            = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
#################################################################################################
#CodeBuild task role
#################################################################################################

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "codebuild-policy"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "s3:*",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
            "ssm:GetParameters",
            "secretsmanager:GetSecretValue"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}

#################################################################################################
#CodePipeLIne task role
#################################################################################################
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = "codepipeline-policy"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "codebuild:StartBuild",
            "codebuild:BatchGetBuilds",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecs:UpdateService",
            "ecs:DescribeServices",
            "iam:PassRole",
            "ecs:*",
            "ec2:*",
            "s3:*"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}