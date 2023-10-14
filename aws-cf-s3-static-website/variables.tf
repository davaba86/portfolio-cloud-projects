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

variable "public_domain" {
  description = "This is the purchased public domain that you own"
  type        = string
}
