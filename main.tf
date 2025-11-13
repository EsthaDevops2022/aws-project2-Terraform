# S3 Bucket for static website hosting
resource "aws_s3_bucket" "project2-bucket-em" {
  bucket = var.s3_bucket_name
}

# S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "project2-bucket-em" {
  bucket = aws_s3_bucket.project2-bucket-em.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "project2-bucket-em" {
  bucket = aws_s3_bucket.project2-bucket-em.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket ACL
resource "aws_s3_bucket_acl" "project2-bucket-em" {
  depends_on = [
    aws_s3_bucket_ownership_controls.project2-bucket-em,
    aws_s3_bucket_public_access_block.project2-bucket-em,
  ]

  bucket = aws_s3_bucket.project2-bucket-em.id
  acl    = "public-read"
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "project2-bucket-em" {
  bucket = aws_s3_bucket.project2-bucket-em.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# S3 Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "project2-bucket-em" {
  bucket = aws_s3_bucket.project2-bucket-em.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.project2-bucket-em.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.project2-bucket-em]
}

# Upload static files to S3
resource "aws_s3_object" "static_files" {
  for_each = fileset(var.static_files_path, "**")

  bucket = aws_s3_bucket.project2-bucket-em.id
  key    = each.value
  source = "${var.static_files_path}/${each.value}"
  etag   = filemd5("${var.static_files_path}/${each.value}")
  content_type = lookup(
    var.content_types,
    try(regexall("\\.[^.]+$", each.value)[0], "default"),
    "binary/octet-stream"
  )
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "project2-bucket-em" {
  comment = "OAI for project2-bucket-em S3 bucket"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "project2-bucket-em" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["project2.esthadevops.com"]

  origin {
    domain_name = aws_s3_bucket.project2-bucket-em.bucket_regional_domain_name
    origin_id   = "S3-project2-bucket-em"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.project2-bucket-em.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-project2-bucket-em"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.wildcard.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"

  }



  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  depends_on = [aws_s3_object.static_files]
}

