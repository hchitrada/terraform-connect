# -----------------------------------------------------------------------------
# CI/CD Layer - Single Pipeline + Website Infrastructure + Flows Pipeline
# -----------------------------------------------------------------------------

module "pipeline" {
  source = "../modules/pipeline"

  project_name      = var.project_name
  aws_region        = var.aws_region
  source_branch     = "main"
  connection_arn    = var.connection_arn
  repository_id     = var.repository_id
  state_bucket_arn  = "arn:aws:s3:::${var.project_name}-tfstate"
  lock_table_arn    = "arn:aws:dynamodb:${var.aws_region}:264161240947:table/${var.project_name}-tfstate-lock"
  approval_email    = var.approval_email
  website_bucket    = aws_s3_bucket.website.bucket
  cloudfront_domain = aws_cloudfront_distribution.website.domain_name
}

# -----------------------------------------------------------------------------
# Flows Pipeline (uncomment after first infra pipeline run)
# Requires: instance IDs and flow IDs from terraform output
# -----------------------------------------------------------------------------
# module "flows_pipeline" {
#   source = "../modules/flows-pipeline"
#
#   project_name          = var.project_name
#   aws_region            = var.aws_region
#   connection_arn        = var.connection_arn
#   flows_repository_id   = "hchitrada/connect-flows"
#   dev_instance_id       = "FILL_AFTER_FIRST_RUN"
#   dev_contact_flow_id   = "FILL_AFTER_FIRST_RUN"
#   prod_instance_id      = "FILL_AFTER_FIRST_RUN"
#   prod_contact_flow_id  = "FILL_AFTER_FIRST_RUN"
#   approval_sns_topic_arn = module.pipeline.sns_topic_arn
#   cloudfront_domain     = aws_cloudfront_distribution.website.domain_name
#   codebuild_role_arn    = module.pipeline.codebuild_role_arn
#   codepipeline_role_arn = module.pipeline.codepipeline_role_arn
#   artifact_bucket       = module.pipeline.artifact_bucket
#   log_group_name        = module.pipeline.log_group_name
# }

# -----------------------------------------------------------------------------
# S3 Website Bucket (Private - served via CloudFront)
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website"

  tags = {
    Name    = "${var.project_name}-website"
    Project = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# CloudFront Origin Access Control
# -----------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.project_name}-website-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -----------------------------------------------------------------------------
# CloudFront Distribution
# -----------------------------------------------------------------------------

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "${var.project_name} - Contact Center Support Page"

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-website"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-website"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 1200
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name    = "${var.project_name}-website-cdn"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# S3 Bucket Policy - Allow CloudFront OAC only
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontOAC"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}
