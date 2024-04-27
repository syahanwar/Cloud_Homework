# Create S3 Bucket
resource "aws_s3_bucket" "terraform-demo-9876" {
  bucket = "terraform-demo-9876"
}

# Upload file to S3
resource "aws_s3_object" "terraform_index" {
  bucket       = aws_s3_bucket.terraform-demo-9876.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

resource "aws_s3_object" "terraform_about" {
  bucket       = aws_s3_bucket.terraform-demo-9876.id
  key          = "about.html"
  source       = "about.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

resource "aws_s3_object" "terraform_contact" {
  bucket       = aws_s3_bucket.terraform-demo-9876.id
  key          = "contact.html"
  source       = "contact.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}
locals {
  css_files = fileset("css", "**/*.css")
}

resource "aws_s3_bucket_object" "css_files" {
  for_each     = { for file in local.css_files : file => file }
  bucket       = aws_s3_bucket.terraform-demo-9876.id
  key          = each.value
  source       = "css/${each.value}"
  content_type = "text/css"                   # Set content type for CSS
  etag         = filemd5("css/${each.value}") # Update this with the correct file path

}

locals {
  image_files = fileset("images", "**/*.*")
}

resource "aws_s3_bucket_object" "image_files" {
  for_each = { for file in local.image_files : file => file }
  bucket   = aws_s3_bucket.terraform-demo-9876.id
  key      = "images/${each.value}"  # You can change the prefix as per your requirement
  source   = "images/${each.value}"
  content_type = lookup({
 "jpg"   = "image/jpeg"
    "jpeg"  = "image/jpeg"
    "png"   = "image/png"
    "gif"   = "image/gif"
    "svg"   = "image/svg+xml"
    "ico"   = "image/x-icon"
  }, lower(regex("[^.]+$", each.value)), "application/octet-stream")
  etag = filemd5("images/${each.value}")  # Update this with the correct file path
}

locals {
  js_files = fileset("js", "**/*.*")
}
resource "aws_s3_bucket_object" "js_files" {
  for_each     = { for file in local.js_files : file => file }
  bucket       = aws_s3_bucket.terraform-demo-9876.id
  key          = each.value
  source       = "js/${each.value}"            # Assuming JavaScript files are in a directory named "js"
  content_type = "application/javascript"      # Set content type for JavaScript
  etag         = filemd5("js/${each.value}")   # Update this with the correct file path
}



# S3 Web hosting
resource "aws_s3_bucket_website_configuration" "terraform_hosting" {
  bucket = aws_s3_bucket.terraform-demo-9876.id

  index_document {
    suffix = "index.html"
  }
}

# S3 public access
resource "aws_s3_bucket_public_access_block" "terraform-demo" {
  bucket              = aws_s3_bucket.terraform-demo-9876.id
  block_public_acls   = false
  block_public_policy = false
}

# S3 public Read policy
resource "aws_s3_bucket_policy" "open_access" {
  bucket = aws_s3_bucket.terraform-demo-9876.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Public_access"
    Statement = [
      {
        Sid       = "IPAllow"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = "${aws_s3_bucket.terraform-demo-9876.arn}/*"
      },
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.terraform-demo]
}