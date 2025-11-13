# Data Sources

# Get the existing hosted zone
data "aws_route53_zone" "hosted_zone" {
  name = "esthadevops.com."
}

# Get the existing SSL certificate 
data "aws_acm_certificate" "wildcard" {
  domain   = "*.esthadevops.com"
  statuses = ["ISSUED"]
  provider = aws.us-east-1
}

# Get your existing CloudFront distribution
data "aws_cloudfront_distribution" "existing" {
  id = "EZ0ZUO3EIKWSA"
}

# Route 53 record
resource "aws_route53_record" "project2" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.record_name
  type    = var.record_type

  alias {
    name                   = data.aws_cloudfront_distribution.existing.domain_name
    zone_id                = data.aws_cloudfront_distribution.existing.hosted_zone_id
    evaluate_target_health = false
  }
}