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
  region = var.aws_region
}

variable "aws_region" {
  description = "Region para desplegar infraestructura"
  type        = string
  default     = "us-east-1"
}

resource "aws_instance" "samj_app" {
  ami           = var.app_ami
  instance_type = "t3.micro"

  tags = {
    Name        = "S.A.M.J. Global Services"
    Environment = "production"
    Owner       = "equipo-iac"
  }
}

variable "app_ami" {
  description = "AMI de la aplicacion"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

