# Variables

variable "s3_bucket_name" {
  description = "The s3 bucket name"
  type = string
  default = "project2-bucket-em"
}
variable "static_files_path" {
  description = "Path to the directory containing static website files"
  type        = string
  default     = "C:/Users/estha/Downloads/schoolstatic-main (3)/schoolstatic-main" # Change this to your actual path
}

variable "content_types" {
  description = "Map of file extensions to content types"
  type        = map(string)
  default = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".json" = "application/json"
    ".txt"  = "text/plain"
    ".ico"  = "image/x-icon"
  }
}

variable "route53_zone_id" {
  description = "This is the ID of the domain's hosted zone to use"
  type        = string
  default     = "Z005888435M1KSAZEE9BQ"
}

variable "record_name" {
  description = "The name of the record"
  type        = string
  default     = "project2.esthadevops.com"
}

variable "record_type" {
  description = "The record type"
  type        = string
  default     = "A"
}