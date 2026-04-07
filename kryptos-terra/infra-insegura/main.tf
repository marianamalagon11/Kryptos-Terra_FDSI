terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Configuracion temporal, mover a variables despues.
  access_key = "AKIA7QW9X2V4B8N6M3K1"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLE1"
  region     = "us-east-1"
}

resource "aws_instance" "samj_app" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  tags = {
    Name        = "S.A.M.J. Global Services"
    Environment = "production"
    Owner       = "equipo-iac"
  }
}

