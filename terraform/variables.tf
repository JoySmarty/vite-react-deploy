# variables.tf
variable "main_bucket_name" {
  description = "The name of the primary S3 bucket"
  default     = "joyimarah.name.ng"
}

variable "redirect_bucket_name" {
  description = "The name of the redirect S3 bucket"
  default     = "www.joyimarah.name.ng"
}

variable "main_domain" {
  description = "Primary domain name"
  default     = "joyimarah.name.ng"
}

variable "zone_name" {
  description = "The DNS zone name (hosted zone root domain)"
  default     = "joyimarah.name.ng"
}

