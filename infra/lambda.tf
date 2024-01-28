resource "aws_iam_role" "poc-elfuerte-lambda-iam-role" {
  name = "poc-elfuerte-lambda-iam-role-tf"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "poc-elfuerte-lambda-permission-policy" {
  name = "poc-elfuerte-lambda-permission-policy-tf"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeAsync",
                "lambda:InvokeFunction"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "poc-elfuerte-iam-policy-attachment" {
  role       = "${aws_iam_role.poc-elfuerte-lambda-iam-role.name}"
  policy_arn = "${aws_iam_policy.poc-elfuerte-lambda-permission-policy.arn}"
}

resource "aws_lambda_permission" "poc-elfuerte-lambda-permission" {
  statement_id = "AllowS3Invoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.poc-elfuerte-lambda.function_name
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.elfuerte-bucket-upload.arn
}

resource "aws_lambda_function" "poc-elfuerte-lambda" {
  function_name = "${var.function_name}"
  role = aws_iam_role.poc-elfuerte-lambda-iam-role.arn
  handler = "POCElfuerteLambda::POCElfuerteLambda.LambdaEntryPoint::FunctionHandlerAsync"
  runtime = "dotnet6"
  timeout = 45
  memory_size = 256
  description = "${var.function_description}"
  package_type = "Zip"
  s3_bucket = "${var.lambda_bucket}"
  s3_key = "${var.lambda_bucket_key}/POCElfuerteLambda.zip"
  source_code_hash = "POCElfuerteLambda.zip.base64sha256"
  skip_destroy = false

  tags = {
    name = "poc-elfuerte"
    environment  = "${var.environment}"
  }
}

resource "aws_lambda_permission" "lambda-api-permission" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-api.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.poc-api-gateway_rest_api.execution_arn}/*"
}

resource "aws_lambda_function" "lambda-api" {
  function_name = "${var.function_name1}"
  role = aws_iam_role.poc-elfuerte-lambda-iam-role.arn
  handler = "LambdaAPI::LambdaAPI.LambdaEntryPoint::FunctionHandlerAsync"
  runtime = "dotnet6"
  timeout = 45
  memory_size = 256
  description = "${var.function_description}"
  package_type = "Zip"
  s3_bucket = "${var.lambda_bucket}"
  s3_key = "${var.lambda_bucket_key}/LambdaAPI.zip"
  source_code_hash = "LambdaAPI.zip.base64sha256"
  skip_destroy = false

  tags = {
    name = "poc-elfuerte"
    environment  = "${var.environment}"
  }
}