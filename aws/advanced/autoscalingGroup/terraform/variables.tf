variable "image_id" {
  type        = string
  default     = "ami-079db87dc4c10ac91"
  description = "id of AMI"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type"
}

variable "key_name" {
  type        = string
  default     = "ec2_asg_kp"
  description = "key pair name"
}
