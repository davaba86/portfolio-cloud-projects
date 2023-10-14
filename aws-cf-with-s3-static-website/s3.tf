resource "aws_s3_bucket" "cf_origin" {
  bucket = "www.mechaconsulting.org"

  tags = {
    Name = "${var.env_name_short}-s3-${lookup(var.aws_regions, "us-east-1")}-mechaconsulting.org"
  }
}

resource "aws_s3_bucket_website_configuration" "cf_origin" {
  bucket = aws_s3_bucket.cf_origin.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.cf_origin.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "cf_origin" {
  bucket = aws_s3_bucket.cf_origin.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Allow CF to read S3 (Get Object)"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.cf_origin.arn}",
          "${aws_s3_bucket.cf_origin.arn}/*"
        ]
        "Condition" = {
          "StringLike" = {
            "aws:Referer" : random_password.cf_custom_header_password.result
          }
        }
      }
    ]
  })
}

resource "aws_s3_object" "object-upload-html" {
  for_each = fileset("html/", "*.html")

  bucket       = aws_s3_bucket.cf_origin.bucket
  key          = each.value
  source       = "html/${each.value}"
  content_type = "text/html"
  etag         = filemd5("html/${each.value}")
}
