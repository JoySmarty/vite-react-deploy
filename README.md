# Vite React App Deployment on AWS using Terraform

This project demonstrates how to deploy a static Vite-based React application to AWS using Terraform. The infrastructure is fully automated and covers everything from S3 hosting to CloudFront distribution and domain DNS setup with Route 53.

## Live Demo

🔗 https://joyimarah.name.ng


## Tech Stack

- [Terraform](https://www.terraform.io/) (v1.8+)
- [AWS S3](https://aws.amazon.com/s3/) – for static site hosting
- [AWS CloudFront](https://aws.amazon.com/cloudfront/) – CDN & HTTPS
- [AWS ACM](https://aws.amazon.com/certificate-manager/) – SSL/TLS Certificates
- [AWS Route 53](https://aws.amazon.com/route53/) – DNS Management
- [WhoGoHost](https://www.whogohost.com/) – Domain Registrar
- [Vite](https://vitejs.dev/) – Build tool for React


## Architecture Overview

[WhoGoHost Domain] ➡ [Route 53 Hosted Zone] ➡ [CloudFront CDN (HTTPS)] ➡ [S3 Static Website]

## Two S3 buckets:

joyimarah.name.ng (main bucket for app files)

www.joyimarah.name.ng (redirect bucket)

## Folder Structure
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── ...
├── dist/ (Vite build output)
└── README.md

## Key Terraform Resources
- aws_s3_bucket: Hosts the static files

- aws_s3_bucket_policy: Allows public access to bucket content

- aws_s3_bucket_website_configuration: Configures static hosting or redirection

- aws_acm_certificate: Issues an SSL certificate (DNS-validated)

- aws_route53_zone & aws_route53_record: Manages DNS

- aws_cloudfront_distribution: Serves app over HTTPS with caching

- null_resource + local-exec: Syncs dist/ files to the S3 bucket
⚙️ Terraform Workflow
Initialize Terraform

bash
Copy
Edit
terraform init
Validate Configuration

bash
Copy
Edit
terraform validate
Preview Infrastructure

bash
Copy
Edit
terraform plan
Apply and Deploy

bash
Copy
Edit
terraform apply
(Optional) Tear Down

bash
Copy
Edit
terraform destroy

🔐 Security Configurations
Ensure your S3 public access is explicitly allowed using:

hcl
Copy
Edit
resource "aws_s3_bucket_public_access_block" "main_block" {
  bucket = aws_s3_bucket.main_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
Also, make sure your IAM user has sufficient permissions (S3, ACM, CloudFront, Route 53).

⚠️ Common Issues I Faced
BlockPublicPolicy error on S3 → Solved with proper PublicAccessBlock

PendingValidation on ACM → Solved by ensuring DNS validation records were created and propagated

website_endpoint deprecation warning → Solved by using aws_s3_bucket_website_configuration

🧪 Build & Upload (Vite)
bash
Copy
Edit
npm run build
aws s3 sync dist/ s3://joyimarah.name.ng
Or via Terraform:

hcl
Copy
Edit
resource "null_resource" "upload_files" {
  provisioner "local-exec" {
    command = "aws s3 sync ../dist s3://${aws_s3_bucket.main_site.id}"
  }
}

