variable "region" {
  default     = ""
  description = "EKS region"
}

variable "vcp_name" {
  default     = ""
  description = "VPC name"
}

variable "vpc_cidr" {
  default     = ""
  description = "VPC cidr"
}

variable "eks_cluster_name" {
  default     = ""
  description = "EKS cluster name"
}

variable "eks_private_subnets" {
  default     = []
  description = "EKS private subnets"

}

variable "eks_public_subnets" {
  default     = []
  description = "EKS public subnets"
}

variable "eks_intra_subnets" {
  default = []
}

variable "eks_instance_types" {
  default = []
}

variable "eks_capacity_type" {
  default = ""
}
