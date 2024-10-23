# Database Security Group for RDS
resource "aws_security_group" "database_sg" {
  name        = "database-security-group"
  description = "Security group for RDS database instances"
  vpc_id      = aws_vpc.my_vpc.id

  # Allow PostgreSQL traffic only from the Application Security Group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application_sg.id] # Only allow traffic from the web app's security group
  }

  # No outbound traffic restrictions
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Postgres-RDS-Database-Security-Group"
  }
}
#Custom parameter group
resource "aws_db_parameter_group" "custom_pg" {
  family = "postgres16"
  name   = "csye6225-pg"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
  parameter {
    name  = "log_connections"
    value = "1"
  }
}
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-private-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "RDS Private Subnet Group"
  }
}
# PostgreSQL RDS instance
resource "aws_db_instance" "postgres_rds" {
  identifier             = var.identifier
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.custom_pg.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "CSYE6225-RDS"
  }
}
