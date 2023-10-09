variable "project_name" {
  description = "Name of the LAB"
  type        = string
}

variable "owner" {
  description = "Your name, e.g. firstname lastname"
  type        = string
}

variable "env_name_long" {
  description = "Environment name, long"
  type        = string
}

variable "env_name_short" {
  description = "Environment name, short"
  type        = string
}

variable "region_code_execution" {
  description = "Region where code will be executed"
  type        = string
}

variable "aws_regions" {
  description = "Dictionary linking aws regions to long name"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "vpc_azs" {
  description = "List of VPC AZs to be used."
  type        = list(string)
}

variable "vpc_subnet_public_range" {
  description = "List of VPC public subnet CIDR range(s)."
  type        = list(string)
}

variable "vpc_subnet_private_range" {
  description = "List of VPC public subnet CIDR range(s)."
  type        = list(string)
}

variable "public_domain" {
  description = "This is the purchased public domain that you own"
  type        = string
}

variable "sg_web_ingress" {
  description = "SG for traffic to/from web tier"
  type        = map(any)
}

variable "disable_acme_tls_prod" {
  description = "Disable ACME TLS certificate for production (max 5 generations each week)"
  type        = bool
}
