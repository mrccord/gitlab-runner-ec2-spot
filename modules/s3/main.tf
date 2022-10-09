resource "aws_s3_bucket" "gitlab-runner-s3" {
  bucket = "gitlab-runner-cache-s3-aws-spot-testing"
  tags = {
    Name = "gitlab-runner-cache-s3"
  }
}
resource "aws_s3_bucket_acl" "gitlab-runner-s3-acl" {
  bucket = aws_s3_bucket.gitlab-runner-s3.id
  acl    = "private"
}
