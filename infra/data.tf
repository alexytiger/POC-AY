data "aws_canonical_user_id" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# data "aws_vpc" "vpc_data" {
  
#   filter {
#     name = "tag:namealias"
#     values = ["${var.vpc}"]
#   }
# }

# data "aws_subnets" "public_subnets" {

#   filter {
#     name = "tag:subnet"
#     values = ["*public*"] 
#   }

#   filter {
#     name = "vpc-id"
#     values = [data.aws_vpc.vpc_data.id]
#   }
# }
