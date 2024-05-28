#################################################################################################
# This file describes the ECR resources: ECR repo, ECR policy, resources to build and push image
#################################################################################################
#Creation of the ECR repos
resource "aws_ecr_repository" "ecr-frontend" {
    name                            = "labcom-frontend"
    force_delete = true
}

resource "aws_ecr_repository" "ecr-backend" {
    name                            = "labcom-backend"
    force_delete = true
}

#The ECR policy describes the management of images in the frondend repo
resource "aws_ecr_lifecycle_policy" "ecr_policy_frontend" {
    repository                      = aws_ecr_repository.ecr-frontend.name
    policy                          = local.ecr_policy
}

#The ECR policy describes the management of images in the backend repo
resource "aws_ecr_lifecycle_policy" "ecr_policy_backend" {
    repository                      = aws_ecr_repository.ecr-backend.name
    policy                          = local.ecr_policy
}


#This is the policy defining the rules for images in the repo
locals {
  ecr_policy = jsonencode({
        "rules":[
            {
                "rulePriority"      : 1,
                "description"       : "Expire images older than 14 days",
                "selection": {
                    "tagStatus"     : "any",
                    "countType"     : "sinceImagePushed",
                    "countUnit"     : "days",
                    "countNumber"   : 14
                },
                "action": {
                    "type"          : "expire"
                }
            }
        ]
    })
}

#The commands below are used to build and push a docker images of the application in the App folder
locals {
  copy_backend                              = "git clone --single-branch --branch CodeLabcom-backend https://github.com/VadimV1/AWS-LAB.git backend"
  copy_frontend                             = "git clone --single-branch --branch CodeLabcom-frontend https://github.com/VadimV1/AWS-LAB.git frontend"
  delete_backend                            = "rm -rf ${var.backend}"
  delete_frontend                           = "rm -rf ${var.frontend}"

  docker_login_command                      = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  
  docker_build_frontend_command             = "docker build -t ${aws_ecr_repository.ecr-frontend.name}:${data.external.frontend_version.result.version} ${var.frontend}"
  docker_tag_frontend_command               = "docker tag ${aws_ecr_repository.ecr-frontend.name}:${data.external.frontend_version.result.version} ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-frontend.name}:${data.external.frontend_version.result.version}"
  docker_push_frontend_command              = "docker push ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-frontend.name}:${data.external.frontend_version.result.version}"
  
  docker_build_backend_command              = "docker build -t ${aws_ecr_repository.ecr-backend.name}:${data.external.backend_version.result.version} ${var.backend}"
  docker_tag_backend_command                = "docker tag ${aws_ecr_repository.ecr-backend.name}:${data.external.backend_version.result.version} ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-backend.name}:${data.external.backend_version.result.version}"
  docker_push_backend_command               = "docker push ${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr-backend.name}:${data.external.backend_version.result.version}"
}
# ------------------------------------------------------------------------------
# Git clone phase
# ------------------------------------------------------------------------------
#Clone the backend and extract the version for image tagging
resource "null_resource" "copy_backend" {
    provisioner "local-exec" {
        command                     = local.copy_backend
    }
    triggers = {
        "run_at"                    = timestamp()
    }
}

data "external" "backend_version" {
  program = ["bash", "-c", <<EOF
  version=$(jq -r '.version' ${var.backend}/package.json)
  echo "{\"version\": \"$version\"}"
  EOF
  ]
  depends_on = [ null_resource.copy_backend ]
}

#Clone the backend and extract the version for image tagging
resource "null_resource" "copy_frontend" {
    provisioner "local-exec" {
        command                     = local.copy_frontend
    }
    triggers = {
        "run_at"                    = timestamp()
    }
}

data "external" "frontend_version" {
  program = ["bash", "-c", <<EOF
  version=$(jq -r '.version' ${var.frontend}/package.json)
  echo "{\"version\": \"$version\"}"
  EOF
  ]
  depends_on = [ null_resource.copy_frontend ]
}

# ------------------------------------------------------------------------------
# Login to phase
# ------------------------------------------------------------------------------
#This resource authenticates you to the ECR service
resource "null_resource" "docker_login" {
    provisioner "local-exec" {
        command                     = local.docker_login_command
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ aws_ecr_repository.ecr-frontend ,data.external.frontend_version]
}
# ------------------------------------------------------------------------------
# Build.,Tag,Push of the backend service to ECR
# ------------------------------------------------------------------------------
#This resource builds the docker image from the Dockerfile in the app folder
resource "null_resource" "docker_backend_build" {
    provisioner "local-exec" {
        command                     = local.docker_build_backend_command 
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on = [ null_resource.docker_login ]
}

#This resource tags the image 
resource "null_resource" "docker_backend_tag" {
    provisioner "local-exec" {
        command                     = local.docker_tag_backend_command
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_backend_build ]
}

#This resource pushes the docker image to the ECR repo
resource "null_resource" "docker_backend_push" {
    provisioner "local-exec" {
        command                     = local.docker_push_backend_command 
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_backend_tag ]
}

resource "null_resource" "delete_backend" {
    provisioner "local-exec" {
        command                     = local.delete_backend
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_backend_push ]
}

# ------------------------------------------------------------------------------
# Build.,Tag,Push of the frontend service to ECR
# ------------------------------------------------------------------------------

#This resource builds the docker image from the Dockerfile in the app folder
resource "null_resource" "docker_frontend_build" {
    provisioner "local-exec" {
        command                     = local.docker_build_frontend_command 
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_backend_tag ]
}

#This resource tags the image 
resource "null_resource" "docker_frontend_tag" {
    provisioner "local-exec" {
        command                     = local.docker_tag_frontend_command
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_frontend_build ]
}

#This resource pushes the docker image to the ECR repo
resource "null_resource" "docker_frontend_push" {
    provisioner "local-exec" {
        command                     = local.docker_push_frontend_command 
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_frontend_tag ]
}

resource "null_resource" "delete_frontend" {
    provisioner "local-exec" {
        command                     = local.delete_frontend
    }
    triggers = {
        "run_at"                    = timestamp()
    }
    depends_on                      = [ null_resource.docker_frontend_push ]
}


