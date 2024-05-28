##########################################################################################
# This file describes the ECS resources: ECS cluster, ECS task definition, ECS service
##########################################################################################

##########################################################################################
# Define the ECS clsuter
##########################################################################################
resource "aws_ecs_cluster" "ecs_cluster" {
    name                                = "${var.domain}-ecs-cluster"
    tags = {
        Name = "${var.domain}-ecs-cluster"
    }
}

##########################################################################################
# Define the ECS service and task for the backend service
##########################################################################################
#The ECS task for the backend service.
resource "aws_ecs_task_definition" "task_definition_backend" {
    family                              = "${var.domain}-web-app"
    requires_compatibilities            = ["FARGATE"]
    network_mode                        = "awsvpc"
    cpu                                 = "256"
    memory                              = "512"
    execution_role_arn                  = aws_iam_role.ecsTaskExecutionRole.arn
    
    # container definitions describes the configurations for the task
    container_definitions               = jsonencode(
    [
    {
        "name"                          : "labcom-backend-container",
        "image"                         : "${aws_ecr_repository.ecr-backend.repository_url}:${data.external.backend_version.result.version}",
        "entryPoint"                    : []
        "essential"                     : true,
        "networkMode"                   : "awsvpc",
        "portMappings"                  : [
                                            {
                                                "containerPort" : var.container_backend_port
                                                "hostPort"      : var.container_backend_port
                                                "protocol"      : "tcp"
                                                "name"          : "backend-port"
                                            },
                                            {
                                                "containerPort" : var.container_frontend_port
                                                "hostPort"      : var.container_frontend_port
                                                "protocol"      : "tcp"
                                                "name"          : "frontend-port"
                                            },
                                            {
                                                "containerPort" : 5432
                                                "hostPort"      : 5432
                                                "protocol"      : "tcp"
                                                "name"          : "postgresql-port"
                                            }
                                          ]
        "environment": [
                                            {
                                            "name": "DB_HOST", "value": aws_db_instance.my_postgres_instance.address
                                            },
                                            {
                                              "name": "DB_USER", "value": "postgres"
                                            },
                                            {
                                              "name": "DB_DATABASE", "value": "postgres"
                                            },
                                            {
                                              "name": "DB_PASSWORD", "value": "12345678"
                                            },
                                            {
                                              "name": "DB_PORT", "value": "5432"
                                            },
                                            {
                                              "name": "PORT", "value": "3001"
                                            }              
                       ]
        "healthCheck" : {
        "command" : ["CMD-SHELL", "curl -f http://localhost:${var.container_backend_port}/data || exit 1"],
        "interval" : 30,
        "timeout" : 5,
        "retries" : 3,
        "startPeriod" : 60
      }
       logConfiguration = {
                                            logDriver = "awslogs"
        options = {
                                            "awslogs-group"         = "/ecs/my-service"
                                            "awslogs-region"        = var.region
                                            "awslogs-stream-prefix" = "ecs"
        }
      }
      enableExecuteCommand = true
    }
    ] 
    )
}

#The ECS service described. This resources allows you to manage tasks
resource "aws_ecs_service" "ecs_backend_service" {
  name                                = "labcom-backend-ecs-service"
  cluster                             = aws_ecs_cluster.ecs_cluster.arn
  task_definition                     = aws_ecs_task_definition.task_definition_backend.arn
  launch_type                         = "FARGATE"
  scheduling_strategy                 = "REPLICA"
  desired_count                       = 2 # the number of tasks you wish to run
  network_configuration {
    subnets                             = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    assign_public_ip                    = false
    security_groups                     = [aws_security_group.backend_sg.id]
  }
  load_balancer {
    target_group_arn                    = aws_lb_target_group.target_backend_group.arn #the target group defined in the alb file
    container_name                      = "labcom-backend-container"
    container_port                      = var.container_backend_port
  }
  depends_on                            = [aws_lb_listener.backend_listener,aws_db_instance.my_postgres_instance ]
}

##########################################################################################
# Define the ECS service and task for the frontend service with configuration of ALB
##########################################################################################
#The ECS task for the backend service.
resource "aws_ecs_task_definition" "task_definition_front" {
    requires_compatibilities            = ["FARGATE"]
    network_mode                        = "awsvpc"
    cpu                                 = "256"
    memory                              = "512"
    execution_role_arn                  = aws_iam_role.ecsTaskExecutionRole.arn
    family                              = "${var.domain}-web-app"
    # container definitions describes the configurations for the task
    container_definitions               = jsonencode(
    [
    {
        "name"                          : "labcom-frontend-container",
        "image"                         : "${aws_ecr_repository.ecr-frontend.repository_url}:${data.external.frontend_version.result.version}",
        "entryPoint"                    : []
        "essential"                     : true,
        "networkMode"                   : "awsvpc",
        "portMappings"                  : [
                                            {
                                                "containerPort" : var.container_frontend_port
                                                "hostPort"      : var.container_frontend_port
                                                "protocol"      : "tcp"
                                                "name"          : "frontend-port"
                                            },
                                            {
                                                "containerPort" : var.container_backend_port
                                                "hostPort"      : var.container_backend_port
                                                "protocol"      : "tcp"
                                                "name"          : "backend-port"
                                            }
                                          ]
        "environment": [
                                            {"name": "REACT_APP_BACKEND_URL", "value": "https://${var.www_domain}:${var.container_backend_port}"}
                       ]
        "healthCheck" : {
        "command" : ["CMD-SHELL", "curl -f http://localhost:${var.container_frontend_port} || exit 1"],
        "interval" : 30,
        "timeout" : 5,
        "retries" : 3,
        "startPeriod" : 60
      }
        logConfiguration = {
                                            logDriver = "awslogs"

                                            options = {
                                              "awslogs-group"         = "/ecs/my-service"
                                              "awslogs-region"        = var.region
                                              "awslogs-stream-prefix" = "ecs"
        }
      }
        enableExecuteCommand = true
    }
    ] 
    )
}
#The ECS service described. This resources allows you to manage tasks
resource "aws_ecs_service" "ecs_frontend_service" {
  name                                = "labcom-frontend-ecs-service"
  cluster                             = aws_ecs_cluster.ecs_cluster.arn
  task_definition                     = aws_ecs_task_definition.task_definition_front.arn
  launch_type                         = "FARGATE"
  scheduling_strategy                 = "REPLICA"
  desired_count                       = 2 # the number of tasks you wish to run
  
  network_configuration {
    subnets                             = [aws_subnet.private_subnet_1.id , aws_subnet.private_subnet_2.id]
    assign_public_ip                    = false
    security_groups                     = [aws_security_group.frontend_sg.id]

  }
# This block registers the tasks to a target group of the loadbalancer.
  load_balancer {
    target_group_arn                    = aws_lb_target_group.target_frontend_group.arn #the target group defined in the alb file
    container_name                      = "labcom-frontend-container"
    container_port                      = var.container_frontend_port
  }
  depends_on                            = [aws_lb_listener.frontend_listener,aws_ecs_service.ecs_backend_service]
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/my-service"
  retention_in_days = 7
}
