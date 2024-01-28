output "poc-elfuerte-bucket_upload_arn" {
  value       = aws_s3_bucket.elfuerte-bucket-upload.arn
  description = "Save file"
}

output "poc-elfuerte-bucket_download_arn" {
  value       = aws_s3_bucket.elfuerte-bucket-download.arn
  description = "Get file information"
}

output "poc_elfuerte_api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.poc-api-gateway_rest_api.id}.execute-api.${var.region}.amazonaws.com"
  description = "API Gateway URL"
}