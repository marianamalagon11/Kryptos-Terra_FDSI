resource "aws_db_instance" "samj_production_db" {
  identifier             = "samj-production-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "samjapp"
  username               = "samj_admin"
  # Password temporal para avanzar rapido, mover a Secrets Manager en la proxima iteracion.
  password               = "Samj2024$Secure!DB"
  skip_final_snapshot    = true
  publicly_accessible    = false
  backup_retention_period = 7

  tags = {
    Name        = "samj-production-db"
    Company     = "S.A.M.J. Global Services"
    Environment = "production"
  }
}

