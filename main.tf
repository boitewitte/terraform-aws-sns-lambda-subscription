module "label" {
  source        = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.2.1"
  namespace     = "${var.namespace}"
  stage         = "${var.environment}"
  name          = "${var.name}"
  tags          = "${var.tags}"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"

  # function_name = "${module.lambda.function_name}"
  function_name      = "${aws_lambda_function.lambda.function_name}"
  principal     = "sns.amazonaws.com"

  source_arn    = "${var.sns_topic_arn}"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn     = "${var.sns_topic_arn}"
  protocol      = "lambda"
  # endpoint      = "${module.lambda.arn}"
  endpoint      = "${aws_lambda_function.lambda.arn}"
}

# Replaced module lambda -> https://github.com/hashicorp/terraform/issues/12570

data "aws_iam_policy_document" "logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role_policy" "logs_policy" {
  count = "${var.logs_policy != false ? 1 : 0}"

  name = "${var.logs_policy}"
  role = "${aws_iam_role.role.id}"

  policy = "${data.aws_iam_policy_document.logs.json}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole"
    ]

    principals = {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Policy: AWSLambdaVPCAccessExecutionRole (arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole)
resource "aws_iam_role_policy_attachment" "network-attachment" {
  role                 = "${aws_iam_role.role.name}"

  policy_arn           = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role" "role" {
  name = "${module.label.id}"

  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_lambda_function" "lambda" {
  filename            = "${var.lambda_filename}"

  function_name       = "${module.label.id}"
  role                = "${aws_iam_role.role.arn}"

  handler             = "${var.lambda_handler}"
  runtime             = "${var.lambda_runtime}"
  source_code_hash    = "${var.lambda_code_hash}"
  memory_size         = "${var.lambda_memory_size}"
  timeout             = "${var.lambda_timeout}"

  tags                = "${module.label.tags}"

  environment         = {
    variables         = "${var.lambda_environment_variables}"
  }

  vpc_config          = {
    subnet_ids          = ["${var.lambda_vpc_subnet_ids}"]
    security_group_ids  = ["${var.lambda_vpc_security_group_ids}"]
  }
}

# Removed because of issue:
# https://github.com/hashicorp/terraform/issues/12570
# 
# module "lambda" {
#   source        = "git@github.com:boitewitte/terraform-aws-lambda.git"

#   name                    = "${var.name}"
#   namespace               = "${var.namespace}"
#   environment             = "${var.environment}"

#   vpc_subnet_ids          = "${var.lambda_vpc_subnet_ids}"
#   vpc_security_group_ids  = "${var.lambda_vpc_security_group_ids}"

#   filename                = "${var.lambda_filename}"
#   handler                 = "${var.lambda_handler}"
#   runtime                 = "${var.lambda_runtime}"
#   source_code_hash        = "${var.lambda_code_hash}"
#   memory_size             = "${var.lambda_memory_size}"
#   timeout                 = "${var.lambda_timeout}"
#   execution_policies_count = "1"
#   execution_policies      = ["${var.lambda_execution_policies}"]

#   environment_variables   = "${merge(module.label.tags, var.lambda_environment_variables)}"
#   dead_letter_config      = "${var.lambda_dead_letter_config}"
#   logs_policy             = "${format("%s-logs-policy", module.label.id)}"

#   tags                    = "${module.label.tags}"
# }
