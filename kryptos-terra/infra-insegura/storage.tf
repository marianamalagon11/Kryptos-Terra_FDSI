resource "aws_s3_bucket" "samj_backups" {
  bucket = "samj-global-backups-prod"

  tags = {
    Name        = "samj-global-backups-prod"
    Company     = "S.A.M.J. Global Services"
    Environment = "production"
  }
}

locals {
  # Token temporal para autenticacion con el servicio externo de backups.
  backup_api_token = "SAMJ-aB3xK9mP2nQ7rT1vW4yZ6cE8hJ0dL5fG"
}

