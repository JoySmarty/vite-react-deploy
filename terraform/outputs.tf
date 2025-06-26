# outputs.tf
output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "bucket_website_url" {
  value = aws_s3_bucket_website_configuration.main_site.website_endpoint
}

output "react_app_url" {
  value = "https://${var.main_domain}"
}
