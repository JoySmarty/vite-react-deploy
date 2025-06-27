# Vite React App Deployment on AWS using Terraform

## 🚀 Project Overview 
This project demonstrates how I deployed a Vite-powered React application on AWS using Terraform for infrastructure provisioning.

It includes a full walkthrough of:

Creating and configuring S3 buckets (for website hosting and redirection)

Setting up ACM SSL certificates for HTTPS

Creating a CloudFront distribution to serve content securely and quickly

Managing DNS records via Route 53

Automating everything with Infrastructure as Code (IaC) using Terraform

✅ Live Demo: https://joyimarah.name.ng


📖 Medium Article: How I Deployed My Vite React App on AWS Using Terraform
https://medium.com/@smartyjoy47/how-i-deployed-my-vite-react-app-on-aws-using-terraform-step-by-step-guide-bfa16e685b3b


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
```bash
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── ...
├── dist/ (Vite build output)
└── README.md
```
## Key Terraform Resources
- aws_s3_bucket: Hosts the static files

- aws_s3_bucket_policy: Allows public access to bucket content

- aws_s3_bucket_website_configuration: Configures static hosting or redirection

- aws_acm_certificate: Issues an SSL certificate (DNS-validated)

- aws_route53_zone & aws_route53_record: Manages DNS

- aws_cloudfront_distribution: Serves app over HTTPS with caching

- null_resource + local-exec: Syncs dist/ files to the S3 bucket
 
⚙️ Terraform Workflow

1. Initialize Terraform
```bash
terraform init
```
2. Validate Configuration
  ```bash 
terraform validate
```
3. Preview Infrastructure
 ```bash
terraform plan
```
4. Apply and Deploy
```bash
terraform apply
```
5. (Optional) Tear Down
```bash
terraform destroy
```
🔐 Security Configurations
to ensure S3 public access is explicitly allowed using:

```bash
resource "aws_s3_bucket_public_access_block" "main_block" {
  bucket = aws_s3_bucket.main_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```
Also, make sure IAM user has sufficient permissions (S3, ACM, CloudFront, Route 53).

⚠️ Common Issues I Faced
- BlockPublicPolicy error on S3 → Solved with proper PublicAccessBlock

- PendingValidation on ACM → Solved by ensuring DNS validation records were created and propagated

- website_endpoint deprecation warning → Solved by using aws_s3_bucket_website_configuration

🧪 Build & Upload (Vite)
via Terraform:
```bash
resource "null_resource" "upload_files" {
  provisioner "local-exec" {
    command = "aws s3 sync ../dist s3://${aws_s3_bucket.main_site.id}"
  }
}
```
