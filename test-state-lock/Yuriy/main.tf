provider "aws"{
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}


resource "aws_iam_user" "s3_user" {
  name = "test-user"
}

resource "aws_iam_user_policy" "user" {
  name = "s3-user-policys"
  user = aws_iam_user.s3_user.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
        ],
        Resource = [
          "${aws_s3_bucket.egency_bucket.arn}",
          "${aws_s3_bucket.egency_bucket.arn}/*",
        ],
      },
    ],
  })
}

resource "aws_iam_access_key" "s3_key" {
  user = aws_iam_user.s3_user.name
}

# Create a new S3 bucket
resource "aws_s3_bucket" "egency_bucket" {
  bucket = "new-bucket-for-egencykg"  # Change this to your desired bucket name
}

output "secret" {
  value = aws_iam_access_key.s3_key.secret
}

output "access-key" {
  value = aws_iam_access_key.s3_key.id
}


resource "aws_s3_bucket_policy" "grant_access" {
  bucket = aws_s3_bucket.egency_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.s3_user.name}"
      },
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.egency_bucket.arn}",
        "${aws_s3_bucket.egency_bucket.arn}/*"
      ]
    }
  ]
}
EOF
depends_on = [aws_s3_bucket.egency_bucket]
}
