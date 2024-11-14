variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-040c33c6a51fd5d96" # 기본값
}

variable "key_pair" {
  description = "ec2 key"
  type        = string
  default     = "ec2-05-key"
}

variable "db_username" {}
variable "db_password" {}