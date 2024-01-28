variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpc" {
  type = string
  default = ""
}

variable "api_gateway_name" {
   type = string
   default = "poc-elfuerte-api"
}

variable "api_gateway_access_control_allow_origin" {
  type    = string
  default = "method.response.header.Access-Control-Allow-Origin"
}

variable "api_gateway_connection_type" {
  type    = string
  default = "INTERNET"
}

variable "api_gateway_content_handling_text" {
  type    = string
  default = "CONVERT_TO_TEXT"
}

variable "api_gateway_content_handling_binary" {
  type    = string
  default = "CONVERT_TO_BINARY"
}

variable "api_gateway_passthrough_behavior" {
  type    = string
  default = "WHEN_NO_MATCH"
}

variable "api_gateway_response_type" {
  type    = string
  default = "application/json"
}

variable "access_control_allow_headers" {
  type    = string
  default = "method.response.header.Access-Control-Allow-Headers"
}

variable "access_control_allow_methods" {
  type    = string
  default = "method.response.header.Access-Control-Allow-Methods"
}

variable "access_control_allow_origin" {
  type    = string
  default = "method.response.header.Access-Control-Allow-Origin"
}

variable "access_control_allow_headers_value" {
  type    = string
  default = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
}

variable "access_control_allow_methods_value" {
  type    = string
  default = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
}

variable "access_control_allow_origin_value" {
  type    = string
  default = "'*'"
}

variable "access_control_allow_credentials" {
  type    = string
  default = "method.response.header.Access-Control-Allow-Credentials"
}


variable "function_name" {
   type = string
   default = "s3-lambda-s3"
}

variable "function_name1" {
   type = string
   default = "lambda-api"
}

variable "function_description" {
  type = string
  default = "An AWS Serverless Application that uses the ASP.NET Core framework running in Amazon Lambda."
}

variable lambda_bucket {
  type = string
  default = "elfuerte-poc"
}

variable lambda_bucket_key {
  type = string
  default = "Elfuerte_POC/Lambda"
}

variable "environment" {
  type        = string
  description = "Enter the environment you're deploying to: "
  default = "dv"
  
  validation {
    condition = (
      var.environment == "dv"
    )
    error_message = "Valid values are: dev."
  }
}