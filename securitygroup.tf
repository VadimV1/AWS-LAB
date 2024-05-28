# ------------------------------------------------------------------------------
# Security Group for alb
# ------------------------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
    vpc_id                      = aws_vpc.vpc.id
    description                 = "Security group for alb"
    revoke_rules_on_delete      = true
    tags = {
      Name = "${var.domain}-sg-alb"
    }
}
# ------------------------------------------------------------------------------
# Alb Security Group Rules - INBOUND
# ------------------------------------------------------------------------------
resource "aws_security_group_rule" "alb_http_ingress" {
    type                        = "ingress"
    from_port                   = 80
    to_port                     = 80
    protocol                    = "TCP"
    description                 = "Allow http inbound traffic from internet"
    security_group_id           = aws_security_group.alb_sg.id
    cidr_blocks                 = ["0.0.0.0/0"] 
}
resource "aws_security_group_rule" "alb_https_ingress" {
    type                        = "ingress"
    from_port                   = 443
    to_port                     = 443
    protocol                    = "TCP"
    description                 = "Allow https inbound traffic from internet"
    security_group_id           = aws_security_group.alb_sg.id
    cidr_blocks                 = ["0.0.0.0/0"] 
}
resource "aws_security_group_rule" "alb_backend_ingress" {
    type                        = "ingress"
    from_port                   = 3001
    to_port                     = 3001
    protocol                    = "TCP"
    description                 = "Allow https inbound traffic from internet"
    security_group_id           = aws_security_group.alb_sg.id
    cidr_blocks                 = ["0.0.0.0/0"] 
}
# ------------------------------------------------------------------------------
# Alb Security Group Rules - OUTBOUND
# ------------------------------------------------------------------------------
resource "aws_security_group_rule" "alb_egress" {
    type                        = "egress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    description                 = "Allow outbound traffic from alb"
    security_group_id           = aws_security_group.alb_sg.id
    cidr_blocks                 = ["0.0.0.0/0"] 
}

# ------------------------------------------------------------------------------
# Security Group for PostgreSQL
# ------------------------------------------------------------------------------
resource "aws_security_group" "db_sg" {
    vpc_id                      = aws_vpc.vpc.id
    description                 = "Security group for ecs app"
    revoke_rules_on_delete      = true
    tags = {
      Name = "${var.domain}-db-sg"
    }
}
# ------------------------------------------------------------------------------
# PostgreSQL Security Group Rules - INBOUND
# ------------------------------------------------------------------------------
resource "aws_security_group_rule" "db_sg_ingress" {
    type                        = "ingress"
    from_port                   = 5432
    to_port                     = 5432
    protocol                    = "tcp"
    description                 = "Allow inbound traffic to DB from ECS"
    security_group_id           = aws_security_group.db_sg.id
    source_security_group_id    = aws_security_group.backend_sg.id
    
}
# ------------------------------------------------------------------------------
# PostgreSQL Security Group Rules - OUTBOUND
# ------------------------------------------------------------------------------
resource "aws_security_group_rule" "db_sg_egress" {
    type                        = "egress"
    from_port                   = 5432
    to_port                     = 5432
    protocol                    = "tcp"
    description                 = "Allow outbound traffic from ECS"
    security_group_id           = aws_security_group.db_sg.id
    source_security_group_id    = aws_security_group.backend_sg.id
}


resource "aws_security_group" "frontend_sg" {
    vpc_id                      = aws_vpc.vpc.id
    description                 = "Security group for frontend app"
    revoke_rules_on_delete      = true
    tags = {
      Name = "${var.domain}-frontend-sg"
    }
}

resource "aws_security_group_rule" "frontend_sg_ingress" {
    type                        = "ingress"
    from_port                   = 3000
    to_port                     = 3000
    protocol                    = "-1"
    description                 = "Allow inbound traffic from ALB"
    security_group_id           = aws_security_group.frontend_sg.id
    source_security_group_id    = aws_security_group.alb_sg.id
    
}

resource "aws_security_group_rule" "frontend_sg_egress" {
    type                        = "egress"
    from_port                   = 3000
    to_port                     = 3000
    protocol                    = "-1"
    description                 = "Allow outbound traffic from ECS"
    security_group_id           = aws_security_group.frontend_sg.id
    cidr_blocks                 = ["0.0.0.0/0"] 
}


resource "aws_security_group" "backend_sg" {
    vpc_id                      = aws_vpc.vpc.id
    description                 = "Security group for backend"
    revoke_rules_on_delete      = true
    tags = {
      Name = "${var.domain}-frontend-sg"
    }
}

resource "aws_security_group_rule" "backend_sg_ingress" {
    type                        = "ingress"
    from_port                   = 3001
    to_port                     = 3001
    protocol                    = "-1"
    description                 = "Allow inbound traffic from the ALB"
    security_group_id           = aws_security_group.backend_sg.id
    source_security_group_id    = aws_security_group.alb_sg.id
    
}

resource "aws_security_group_rule" "backend_sg_egress" {
    type                        = "egress"
    from_port                   = 3001
    to_port                     = 3001
    protocol                    = "-1"
    description                 = "Allow outbound traffic from the backend service"
    security_group_id           = aws_security_group.backend_sg.id
    cidr_blocks                 = ["0.0.0.0/0"] 
}