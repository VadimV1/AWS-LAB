resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "postresql-db-group"
  }
}

resource "aws_db_parameter_group" "postgresql_parameters" {
  name        = "custom-postgresql-parameters"
  family      = "postgres16"  # Use the appropriate PostgreSQL version
  description = "Custom PostgreSQL parameters for RDS"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}


resource "aws_db_instance" "my_postgres_instance" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"
  identifier           = "postgresdb"
  db_name              = "postgres"
  username             = "postgres"
  password             = "12345678"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
  multi_az             = false
  parameter_group_name = aws_db_parameter_group.postgresql_parameters.name
}