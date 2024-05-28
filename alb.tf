#################################################################################################
# This file describes the Load Balancer resources: ALB, ALB target group, ALB listener
#################################################################################################

#Defining the Application Load Balancer
resource "aws_alb" "application_load_balancer" {
  internal                  = false
  load_balancer_type        = "application"
  subnets                   = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  security_groups           = [aws_security_group.alb_sg.id]
  tags = {
      Name = "${var.domain}-alb"
    }
}

resource "aws_lb_target_group" "target_frontend_group" {
  name                      = "labcom-frontend"
  port                      = var.container_frontend_port
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = aws_vpc.vpc.id
  
  tags={
        Name = "${var.domain}-frontend-target-group"
    }
}

resource "aws_lb_target_group" "target_backend_group" {
  name                      = "labcom-backend"
  port                      = var.container_backend_port
  protocol                  = "HTTP"
  target_type               = "ip"
  vpc_id                    = aws_vpc.vpc.id
  health_check {
    path                = "/data"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
  tags={
        Name = "${var.domain}-backend-target-group"
    }
}


#Defines an HTTP Listener for the ALB
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn         = aws_alb.application_load_balancer.arn
  port                      = "443"
  protocol                  = "HTTPS"
  ssl_policy                = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.certificate.arn
  default_action {
    type                    = "forward"
    target_group_arn        = aws_lb_target_group.target_frontend_group.arn
  }
  
  tags={
        Name = "${var.domain}-https-frontend-listener"
    }
}

#Defines an HTTP Listener for the ALB
resource "aws_lb_listener" "http_frontend_listener" {
  load_balancer_arn         = aws_alb.application_load_balancer.arn
  port                      = "80"
  protocol                  = "HTTP"
  
  default_action {
    type                    = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags={
        Name = "${var.domain}-http-frontend-listener"
    }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn         = aws_alb.application_load_balancer.arn
  port                      = "3001"
  protocol                  = "HTTPS"
  ssl_policy                = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.certificate.arn
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Access denied"
      status_code  = "403"
    }
  }
  tags={
        Name = "${var.domain}-alb-frontend-listener"
    }
}

resource "aws_lb_listener_rule" "frontend_https_header_restriction" {
  listener_arn = aws_lb_listener.backend_listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_backend_group.arn
  }

  condition {
    http_header {
      http_header_name = "Referer"
      values           = ["https://13337labs.com/"]
    }
  }
}