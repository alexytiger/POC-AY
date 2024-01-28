resource "aws_s3_bucket_ownership_controls" "bucket-upload" {
  bucket = aws_s3_bucket.elfuerte-bucket-upload.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket-upload" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket-upload]
  bucket = aws_s3_bucket.elfuerte-bucket-upload.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "READ"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_policy" "elfuerte-bucket-download" {
  bucket = aws_s3_bucket.elfuerte-bucket-download.id
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowS3LambdaS3Access",
      "Effect":"Allow",
      "Principal": {
        "AWS": "${aws_iam_role.poc-elfuerte-lambda-iam-role.arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject",
        "s3:PutObject"
      ],
      "Resource":[
        "${aws_s3_bucket.elfuerte-bucket-download.arn}/*",
        "${aws_s3_bucket.elfuerte-bucket-download.arn}"
        ]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_policy" "elfuerte-bucket-upload" {
  bucket = aws_s3_bucket.elfuerte-bucket-upload.id
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowLambdaAccess",
      "Effect":"Allow",
      "Principal": {
        "AWS": "${aws_iam_role.poc-elfuerte-lambda-iam-role.arn}"
      },
      "Action":[
        "s3:PutObject"
      ],
      "Resource":[
        "${aws_s3_bucket.elfuerte-bucket-upload.arn}/*",
        "${aws_s3_bucket.elfuerte-bucket-upload.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_s3_bucket" "elfuerte-bucket-upload" {
  bucket        = "poc-elfuerte-${var.environment}-upload"
  force_destroy = true
  tags =  {
    name = "poc-elfuerte"
    environment  = "${var.environment}"
  }
}

resource "aws_s3_bucket" "elfuerte-bucket-download" {
  bucket        = "poc-elfuerte-${var.environment}-download"
  force_destroy = true
  tags =  {
    name = "poc-elfuerte"
    environment  = "${var.environment}"
  }
}

resource "aws_s3_bucket_notification" "aws_s3_bucket_notification" {
  bucket = aws_s3_bucket.elfuerte-bucket-upload.id 

  lambda_function {
    lambda_function_arn = aws_lambda_function.poc-elfuerte-lambda.arn
    events = [ "s3:ObjectCreated:*" ]
  }

  depends_on = [aws_lambda_permission.poc-elfuerte-lambda-permission]
}