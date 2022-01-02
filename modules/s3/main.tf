resource "aws_s3_bucket" "gitlab-runner-s3" {
  bucket = "gitlab-runner-cache-s3"
  acl    = "private"

  tags = {
    Name = "gitlab-runner-cache-s3"
  }
}
