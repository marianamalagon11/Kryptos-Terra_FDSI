resource "aws_s3_bucket" "samj_backups" {
  bucket = "samj-global-backups-prod"

  tags = {
    Name        = "samj-global-backups-prod"
    Company     = "S.A.M.J. Global Services"
    Environment = "production"
  }
}

# El token debe llegar desde un gestor de secretos o variable de entorno.
variable "backup_api_token" {
  description = "Token para autenticacion con servicio externo de backups"
  type        = string
  sensitive   = true
}

