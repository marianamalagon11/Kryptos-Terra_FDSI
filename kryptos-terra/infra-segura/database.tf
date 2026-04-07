resource "aws_db_instance" "samj_production_db" {
  identifier              = "samj-production-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "samjapp"
  username                = var.db_admin_username
  password                = var.db_admin_password
  skip_final_snapshot     = true
  publicly_accessible     = false
  backup_retention_period = 7

  tags = {
    Name        = "samj-production-db"
    Company     = "S.A.M.J. Global Services"
    Environment = "production"
  }
}

variable "db_admin_username" {
  description = "Usuario administrador de RDS"
  type        = string
}

variable "db_admin_password" {
  description = "Password administrador de RDS"
  type        = string
  sensitive   = true
}

