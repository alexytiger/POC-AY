resource "aws_iam_role" "poc-elfuerte-api-gateway-iam-role" {
  name        = "poc-elfuerte-api-gateway-iam-role-tf"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "apigateway.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })  
}

resource "aws_iam_role_policy_attachment" "poc-elfuerte-api-gateway-iam-policy-attachment" {
  role       = "${aws_iam_role.poc-elfuerte-api-gateway-iam-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_api_gateway_rest_api" "poc-api-gateway_rest_api" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Poc Elfuerte API Gateway"
      version = "1.0"
    },
  })
  name = "${var.api_gateway_name}"
  binary_media_types = ["*/*"]
  endpoint_configuration {
    types = ["REGIONAL"]
  } 
}

resource "aws_api_gateway_model" "emptymodel" {
  rest_api_id  = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  name         = "Empty"
  description  = "This is a default empty schema model"
  content_type = "application/json"
  schema       = "{\n  \"$schema\": \"http://json-schema.org/draft-04/schema#\",\n  \"title\" : \"Empty Schema\",\n  \"type\" : \"object\"\n}"
}

resource "aws_api_gateway_resource" "api" {
  parent_id   = aws_api_gateway_rest_api.poc-api-gateway_rest_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "file" {
  rest_api_id = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "file"
}

resource "aws_api_gateway_resource" "fileproxy" {
  rest_api_id = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  parent_id   = aws_api_gateway_resource.file.id
  path_part   = "{proxy+}"
}

#---------------------OPTIONS METHOD----------------------------------
resource "aws_api_gateway_method" "fileoptions" {
  rest_api_id        = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id        = aws_api_gateway_resource.fileproxy.id
  http_method        = "OPTIONS"
  authorization      = "NONE"
  api_key_required   = false
  request_parameters = {}
}

resource "aws_api_gateway_method_response" "fileoptionsresponse" {
  rest_api_id     = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id     = aws_api_gateway_resource.fileproxy.id
  http_method     = aws_api_gateway_method.fileoptions.http_method
  status_code     = "200"
  response_models = { "${var.api_gateway_response_type}" = aws_api_gateway_model.emptymodel.name }
  response_parameters = {
    "${var.access_control_allow_headers}" = true,
    "${var.access_control_allow_methods}" = true,
    "${var.access_control_allow_origin}"  = true
  }
  depends_on = [aws_api_gateway_method.fileoptions]
}

resource "aws_api_gateway_integration" "fileoptionsintegration" {
  rest_api_id          = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id          = aws_api_gateway_resource.fileproxy.id
  http_method          = aws_api_gateway_method.fileoptions.http_method
  type                 = "MOCK"
  passthrough_behavior = "${var.api_gateway_passthrough_behavior}"
  request_parameters   = {}
  request_templates    = { "${var.api_gateway_response_type}" : "{\"statusCode\": 200}" }
  connection_type      = "${var.api_gateway_connection_type}"
  depends_on           = [aws_api_gateway_method.fileoptions]
}

resource "aws_api_gateway_integration_response" "fileoptions_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id = aws_api_gateway_resource.fileproxy.id
  http_method = aws_api_gateway_method.fileoptions.http_method
  status_code = aws_api_gateway_method_response.fileoptionsresponse.status_code
  response_parameters = {
    "${var.access_control_allow_headers}" = "${var.access_control_allow_headers_value}",
    "${var.access_control_allow_methods}" = "${var.access_control_allow_methods_value}",
    "${var.access_control_allow_origin}"  = "${var.access_control_allow_origin_value}"
  }
  response_templates = { "${var.api_gateway_response_type}" : "" }
  depends_on = [
    aws_api_gateway_resource.fileproxy,
    aws_api_gateway_method.fileoptions,
    aws_api_gateway_method_response.fileoptionsresponse
  ]
}
#---------------------END OPTIONS METHOD----------------------------------

#---------------------POST METHOD----------------------------------
resource "aws_api_gateway_method" "filepost" {
  rest_api_id   = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.fileproxy.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_method_response" "filepostresponse" {
  rest_api_id     = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id     = aws_api_gateway_resource.fileproxy.id
  http_method     = aws_api_gateway_method.filepost.http_method
  status_code     = "200"
  response_parameters = {
    "${var.api_gateway_access_control_allow_origin}" = true
  }
  depends_on = [aws_api_gateway_method.filepost]
}

resource "aws_api_gateway_integration" "filepostintegration" {
  rest_api_id             = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.fileproxy.id
  http_method             = aws_api_gateway_method.filepost.http_method
  timeout_milliseconds    = 29000
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     =  aws_lambda_function.lambda-api.invoke_arn
  connection_type         = "${var.api_gateway_connection_type}"
  content_handling        = "${var.api_gateway_content_handling_binary}"
  depends_on              = [aws_api_gateway_method.filepost]
}

resource "aws_api_gateway_integration_response" "filepostintegrationresponse" {
  rest_api_id        = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id        = aws_api_gateway_resource.fileproxy.id
  http_method        = aws_api_gateway_method.filepost.http_method
  status_code        = aws_api_gateway_method_response.filepostresponse.status_code
  response_templates = { "${var.api_gateway_response_type}" : "" }

  depends_on = [
    aws_api_gateway_resource.fileproxy,
    aws_api_gateway_method.filepost,
    aws_api_gateway_method_response.filepostresponse,
    aws_api_gateway_integration.filepostintegration
  ]
}
#---------------------END POST METHOD----------------------------------

#---------------------GET METHOD----------------------------------
resource "aws_api_gateway_method" "fileget" {
  rest_api_id   = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.fileproxy.id
  http_method   = "GET"
  authorization = "NONE"
  api_key_required = false
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_method_response" "filegetresponse" {
  rest_api_id     = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id     = aws_api_gateway_resource.fileproxy.id
  http_method     = aws_api_gateway_method.fileget.http_method
  status_code     = "200"
  response_parameters = {
    "${var.api_gateway_access_control_allow_origin}" = true
  }
  depends_on = [aws_api_gateway_method.fileget]
}

resource "aws_api_gateway_integration" "filegetintegration" {
  rest_api_id             = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.fileproxy.id
  http_method             = aws_api_gateway_method.fileget.http_method
  timeout_milliseconds    = 29000
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     =  aws_lambda_function.lambda-api.invoke_arn
  connection_type         = "${var.api_gateway_connection_type}"
  content_handling        = "${var.api_gateway_content_handling_text}"
  depends_on              = [aws_api_gateway_method.fileget]
}

resource "aws_api_gateway_integration_response" "filegetintegrationresponse" {
  rest_api_id        = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id        = aws_api_gateway_resource.fileproxy.id
  http_method        = aws_api_gateway_method.fileget.http_method
  status_code        = aws_api_gateway_method_response.filegetresponse.status_code
  response_templates = { "${var.api_gateway_response_type}" : "" }

  depends_on = [
    aws_api_gateway_resource.fileproxy,
    aws_api_gateway_method.fileget,
    aws_api_gateway_method_response.filegetresponse,
    aws_api_gateway_integration.filegetintegration
  ]
}
#---------------------END GET METHOD----------------------------------

#---------------------ANY METHOD----------------------------------
resource "aws_api_gateway_method" "fileany" {
  rest_api_id   = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.fileproxy.id
  http_method   = "ANY"
  authorization = "NONE"
  api_key_required = false
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_method_response" "fileanyresponse" {
  rest_api_id = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id = aws_api_gateway_resource.fileproxy.id
  http_method = aws_api_gateway_method.fileany.http_method
  status_code = "200"
  response_parameters = {
    "${var.api_gateway_access_control_allow_origin}" = true
  }
  depends_on = [aws_api_gateway_method.fileany]
}

resource "aws_api_gateway_integration" "fileanyintegration" {
  rest_api_id             = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id             = aws_api_gateway_resource.fileproxy.id
  http_method             = aws_api_gateway_method.fileany.http_method
  timeout_milliseconds    = 29000
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     =  aws_lambda_function.lambda-api.invoke_arn
  connection_type         = "${var.api_gateway_connection_type}"
  content_handling        = "${var.api_gateway_content_handling_text}"
  # passthrough_behavior    = "${var.api_gateway_passthrough_behavior}" 
  depends_on              = [aws_api_gateway_method.fileany]
}

resource "aws_api_gateway_integration_response" "fileany_integration_response" {
  rest_api_id        = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  resource_id        = aws_api_gateway_resource.fileproxy.id
  http_method        = aws_api_gateway_method.fileany.http_method
  status_code        = aws_api_gateway_method_response.fileanyresponse.status_code
  response_templates = { "${var.api_gateway_response_type}" : "" }

  depends_on = [
    aws_api_gateway_integration.fileanyintegration,
    aws_api_gateway_resource.fileproxy,
    aws_api_gateway_method.fileany,
    aws_api_gateway_method_response.fileanyresponse
  ]
}
#---------------------END ANY METHOD----------------------------------

resource "aws_api_gateway_gateway_response" "default_4xx" {
  rest_api_id   = "${aws_api_gateway_rest_api.poc-api-gateway_rest_api.id}"
  response_type = "DEFAULT_4XX"
  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_gateway_response" "default_5xx" {
  rest_api_id   = "${aws_api_gateway_rest_api.poc-api-gateway_rest_api.id}"
  response_type = "DEFAULT_5XX"
  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'" 
  }
}

resource "aws_api_gateway_gateway_response" "access_denied" {
  rest_api_id   = "${aws_api_gateway_rest_api.poc-api-gateway_rest_api.id}"
  response_type = "ACCESS_DENIED"
  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }
  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'" 
  }
}

resource "aws_api_gateway_deployment" "poc_api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  depends_on = [    
    aws_api_gateway_gateway_response.default_4xx,
    aws_api_gateway_gateway_response.default_5xx,
    aws_api_gateway_gateway_response.access_denied
  ]
  triggers = {
    redeployment = sha1(join(",", [
      jsonencode(aws_api_gateway_resource.api.id),
      jsonencode(aws_api_gateway_resource.file.id),
      jsonencode(aws_api_gateway_resource.fileproxy.id),

      jsonencode(aws_api_gateway_method.fileoptions.id),
      jsonencode(aws_api_gateway_method_response.fileoptionsresponse.id),
      jsonencode(aws_api_gateway_integration.fileoptionsintegration.id),
      jsonencode(aws_api_gateway_integration_response.fileoptions_integration_response.id),

      jsonencode(aws_api_gateway_method.filepost),
      jsonencode(aws_api_gateway_method_response.filepostresponse),
      jsonencode(aws_api_gateway_integration.filepostintegration),
      jsonencode(aws_api_gateway_integration_response.filepostintegrationresponse),

      jsonencode(aws_api_gateway_method.fileget),
      jsonencode(aws_api_gateway_method_response.filegetresponse),
      jsonencode(aws_api_gateway_integration.filegetintegration),
      jsonencode(aws_api_gateway_integration_response.filegetintegrationresponse),

      jsonencode(aws_api_gateway_method.fileany.id),
      jsonencode(aws_api_gateway_method_response.fileanyresponse.id),
      jsonencode(aws_api_gateway_integration.fileanyintegration.id),
      jsonencode(aws_api_gateway_integration_response.fileany_integration_response.id),

      jsonencode(aws_api_gateway_gateway_response.default_4xx.id),
      jsonencode(aws_api_gateway_gateway_response.default_5xx.id),
      jsonencode(aws_api_gateway_gateway_response.access_denied.id)
    ]))

  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "poc_api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.poc_api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.poc-api-gateway_rest_api.id
  stage_name    = "v1"
}