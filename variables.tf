variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-040c33c6a51fd5d96" # 기본값
}

variable "db_username" {}
variable "db_password" {}