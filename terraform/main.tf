terraform {
  required_version = ">= 1.8.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "main_site" {
  bucket = var.main_bucket_name
  force_destroy = true

}

resource "aws_s3_bucket_public_access_block" "main_block" {
  bucket = aws_s3_bucket.main_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_website_configuration" "main_site" {
  bucket = aws_s3_bucket.main_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}



resource "aws_s3_bucket_policy" "main_policy" {
  bucket = aws_s3_bucket.main_site.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = ["${aws_s3_bucket.main_site.arn}/*"]
      }
    ]
  })
   depends_on = [aws_s3_bucket_public_access_block.main_block]
}

resource "aws_s3_bucket" "redirect_site" {
  bucket = var.redirect_bucket_name
  force_destroy = true

  
}

resource "aws_s3_bucket_website_configuration" "redirect_site_config" {
  bucket = aws_s3_bucket.redirect_site.id

  redirect_all_requests_to {
    host_name = var.main_bucket_name
    protocol  = "https"
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.main_domain
  validation_method = "DNS"

  subject_alternative_names = ["www.${var.main_domain}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_zone" "primary" {
  name = var.main_domain
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.main_site.bucket_regional_domain_name
    origin_id   = "mainS3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "mainS3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [var.main_domain, "www.${var.main_domain}"]
  depends_on = [aws_acm_certificate_validation.cert_validation]
}

resource "aws_route53_record" "main_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.main_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.main_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "null_resource" "upload_files" {
  provisioner "local-exec" {
    command = "aws s3 sync ../dist s3://${aws_s3_bucket.main_site.id}"
  }

  depends_on = [aws_s3_bucket.main_site]
}