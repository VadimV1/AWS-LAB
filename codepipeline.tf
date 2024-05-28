#################################################################################################
# Create the pipeline skeleton for the frontend
#################################################################################################
resource "aws_codepipeline" "frontend_cicd_pipeline" {
  name     = "labcom-frontend-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.frontend_pipeline_bucket.bucket
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      namespace        = "source_variables"
      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_frontend_branch
        OAuthToken = var.github_token
        PollForSourceChanges = false
      }
    }

  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.fronted_project.name
        EnvironmentVariables = jsonencode([
          {
            name  = "COMMIT_MESSAGE"
            value = "#{source_variables.CommitMessage}"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["build_output"]
      configuration = {
        ClusterName       = aws_ecs_cluster.ecs_cluster.name
        ServiceName       = aws_ecs_service.ecs_frontend_service.name
        FileName          = "imagedefinitions.json"
      }
    }
  }
}

#Create the S# bucket to store the code for the pipeline
resource "aws_s3_bucket" "frontend_pipeline_bucket" {
  bucket = "${var.domain}-frontend-pipeline-bucket"
  force_destroy = true
  tags = {
    Name = "${var.domain}-frontend-pipeline-bucket"
  }
}

#################################################################################################
# Create the webhook for the frontend pipeline
#################################################################################################

#declearing a secret that the two sides can auth between them
locals {
  frontend_webhook_secret = "frontend-super-secret"
}

# Create the CodePipeline webhook into a GitHub repository.
resource "aws_codepipeline_webhook" "frontend_labcom_webhook" {
  name            = "labcom-frontend-webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "GitHub"
  target_pipeline = aws_codepipeline.frontend_cicd_pipeline.name

  authentication_configuration {
    secret_token = local.frontend_webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.github_frontend_branch}"
  }
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "frontend_labcom_webhook" {
    repository = var.github_repo
    configuration {
        url          = aws_codepipeline_webhook.frontend_labcom_webhook.url
        content_type = "json"
        insecure_ssl = true
        secret       = local.frontend_webhook_secret
    }

    events = ["push"]
}

#################################################################################################
# Create the pipeline skeleton for the backend
#################################################################################################
resource "aws_codepipeline" "backend_cicd_pipeline" {
  name     = "labcom-backend-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.backend_pipeline_bucket.bucket
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      namespace        = "source_variables"
      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_backend_branch
        OAuthToken = var.github_token
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.backend_project.name
        EnvironmentVariables = jsonencode([
          {
            name  = "COMMIT_MESSAGE"
            value = "#{source_variables.CommitMessage}"
            type  = "PLAINTEXT"
          }
        ])
      }
       
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["build_output"]
      configuration = {
        ClusterName       = aws_ecs_cluster.ecs_cluster.name
        ServiceName       = aws_ecs_service.ecs_backend_service.name
        FileName          = "imagedefinitions.json"
      }
    }
  }
}

#Create the S# bucket to store the code for the pipeline
resource "aws_s3_bucket" "backend_pipeline_bucket" {
  bucket = "${var.domain}-backend-pipeline-bucket"
  force_destroy = true
  tags = {
    Name = "${var.domain}-backend-pipeline-bucket"
  }
}

#################################################################################################
# Create the webhook for the backend pipeline
#################################################################################################

#declearing a secret that the two sides can auth between them
locals {
  backend_webhook_secret = "backend-super-secret"
}

# Create the CodePipeline webhook into a GitHub repository.
resource "aws_codepipeline_webhook" "backend_labcom_webhook" {
  name            = "labcom-backend-webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "GitHub"
  target_pipeline = aws_codepipeline.backend_cicd_pipeline.name

  authentication_configuration {
    secret_token = local.backend_webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.github_backend_branch}"
  }
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "backend-labcom-webhook" {
    repository = var.github_repo
    configuration {
        url          = aws_codepipeline_webhook.backend_labcom_webhook.url
        content_type = "json"
        insecure_ssl = true
        secret       = local.backend_webhook_secret
    }

    events = ["push"]
}
