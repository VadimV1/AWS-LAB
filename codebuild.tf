#################################################################################################
# Create a CodeBuild propject for the frontend service
#################################################################################################
resource "aws_codebuild_project" "fronted_project" {
  name           = "${var.domain}-frontend-codebuild-project"
  description    = "test_codebuild_project_cache"
  build_timeout  = "5"
  queued_timeout = "5"
  
  service_role = aws_iam_role.codebuild_role.arn
  
  artifacts {
    type = "CODEPIPELINE"
  }
  
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
  }

  source {
  type            = "CODEPIPELINE"
  buildspec = <<EOF
  version: 0.2

  phases:
    install:
      runtime-versions:
         nodejs: 21
    pre_build:
      commands:
        - VERSION=$(jq -r .version package.json)
        - echo $VERSION
        - MAJOR=$(echo $VERSION | cut -d. -f1)
        - MINOR=$(echo $VERSION | cut -d. -f2)
        - PATCH=$(echo $VERSION | cut -d. -f3)
        - |
          #!/bin/bash
          case "$COMMIT_MESSAGE" in
            *MAJOR*)
              MAJOR=$((MAJOR + 1))
              ;;
            *MINOR*)
              MINOR=$((MINOR + 1))
              ;;
            *)
              PATCH=$((PATCH + 1))
              ;;
          esac
        - NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        - echo Logging in to Amazon ECR...
        - aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
    build:
      commands:
        - echo Building the Docker image...
        - docker build -t ${aws_ecr_repository.ecr-frontend.name}:$NEW_VERSION .
        - docker tag ${aws_ecr_repository.ecr-frontend.name}:$NEW_VERSION ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-frontend.name}:$NEW_VERSION
    post_build:
      commands:
        - echo Pushing the Docker image...
        - docker push ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-frontend.name}:$NEW_VERSION
        - echo Creating imagedefinitions.json...
        - printf '[{"name":"labcom-frontend-container","imageUri":"%s"}]' ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-frontend.name}:$NEW_VERSION > imagedefinitions.json
  artifacts:
    files:
      - '**/*'
      - 'imagedefinitions.json'
  discard-paths: yes
  EOF
  git_clone_depth = 1
  }
  source_version = "CodeLabcom-frontend"
  tags = {
    Name = "${var.domain}-frontend-codebuild-project"
  }
}

#################################################################################################
# Create a CodeBuild propject for the backend service
#################################################################################################
resource "aws_codebuild_project" "backend_project" {
  name           = "${var.domain}-backend-codebuild-project"
  description    = "test_codebuild_project_cache"
  build_timeout  = "5"
  queued_timeout = "5"
  
  service_role = aws_iam_role.codebuild_role.arn
  
  artifacts {
    type = "CODEPIPELINE"
  }
  
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true
  }

  source {
  type            = "CODEPIPELINE"
  buildspec = <<EOF
  version: 0.2

  phases:
    install:
      runtime-versions:
         nodejs: 21
    pre_build:
      commands:
        - VERSION=$(jq -r .version package.json)
        - echo $VERSION
        - MAJOR=$(echo $VERSION | cut -d. -f1)
        - MINOR=$(echo $VERSION | cut -d. -f2)
        - PATCH=$(echo $VERSION | cut -d. -f3)
        - |
          #!/bin/bash
          case "$COMMIT_MESSAGE" in
            *MAJOR*)
              MAJOR=$((MAJOR + 1))
              ;;
            *MINOR*)
              MINOR=$((MINOR + 1))
              ;;
            *)
              PATCH=$((PATCH + 1))
              ;;
          esac
        - NEW_VERSION="$MAJOR.$MINOR.$PATCH"
        - echo Logging in to Amazon ECR...
        - aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com
    build:
      commands:
        - echo Building the Docker image...
        - docker build -t ${aws_ecr_repository.ecr-backend.name}:$NEW_VERSION .
        - docker tag ${aws_ecr_repository.ecr-backend.name}:$NEW_VERSION ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-backend.name}:$NEW_VERSION
    post_build:
      commands:
        - echo Pushing the Docker image...
        - docker push ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-backend.name}:$NEW_VERSION
        - echo Creating imagedefinitions.json...
        - printf '[{"name":"labcom-backend-container","imageUri":"%s"}]' ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-backend.name}:$NEW_VERSION > imagedefinitions.json
  artifacts:
    files:
      - '**/*'
      - 'imagedefinitions.json'
  discard-paths: yes
  EOF
  git_clone_depth = 1
  }
  source_version = "CodeLabcom-backend"
  tags = {
    Name = "${var.domain}-backend-codebuild-project"
  }
}