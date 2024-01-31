variable "bucketName" {
  type        = string
  default     = "tarava-sysnet-s3-website-test3"
  description = "The Bucket Name"
}

variable "block_public_acls" {
  type        = bool
  default     = false
  description = "block public acls"
}

variable "block_public_policy" {
  type        = bool
  default     = false
  description = "block public policy"
}

variable "ignore_public_acls" {
  type        = bool
  default     = false
  description = "ignore public acls"
}

variable "restrict_public_buckets" {
  type        = bool
  default     = false
  description = "restrict public buckets"
}

