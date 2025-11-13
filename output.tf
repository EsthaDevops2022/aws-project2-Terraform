# Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.project2-bucket-em.id
}

output "s3_bucket_website_endpoint" {
  description = "S3 static website hosting endpoint"
  value       = aws_s3_bucket_website_configuration.project2-bucket-em.website_endpoint
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.project2-bucket-em.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.project2-bucket-em.id
}

output "uploaded_files" {
  description = "List of files uploaded to S3"
  value       = keys(aws_s3_object.static_files)
}

