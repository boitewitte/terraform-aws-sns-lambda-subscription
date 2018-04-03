variable "namespace" {
  type = "string"
  description = "The namespace for the Lambda function"
}

variable "environment" {
  type = "string"
  description = "The environment (stage) for the Lambda function"
}

variable "name" {
  type = "string"
  description = "The name for the Lambda function"
}

variable "tags" {
  type = "map"
  description = "describe your variable"
  default = {}
}

variable "sns_topic_arn" {
  type = "string"
  description = "ARN for the SNS topic"
}

variable "lambda_code_hash" {
  type = "string"
  description = "Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3_key."
}

variable "lambda_dead_letter_config" {
  type = "map"
  description = "Nested block to configure the function's dead letter queue."
  default = {}
}

variable "lambda_filename" {
  type = "string"
  description = "The path to the function's deployment package within the local filesystem."
}

variable "lambda_handler" {
  type = "string"
  description = "The function entrypoint in your code."
}

variable "lambda_environment_variables" {
  type = "map"
  description = "A map that defines environment variables for the Lambda function."
  default = {}
}

variable "lambda_memory_size" {
  type = "string"
  description = "Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128."
  default = "128"
}

variable "lambda_runtime" {
  type = "string"
  description = "The runtime environment for the Lambda function you are uploading. (nodejs, nodejs4.3, nodejs6.10, java8, python2.7, python3.6, dotnetcore1.0, nodejs4.3-edge)"
}

variable "lambda_timeout" {
  type = "string"
  description = "The amount of time your Lambda Function has to run in seconds. Defaults to 3."
  default = "3"
}

variable "lambda_execution_policies" {
  type = "list"
  description = "List of Lambda Execution Policy ARNs"
  default = []
}

variable "lambda_vpc_subnet_ids" {
  type = "list"
  description = "A list of subnet IDs associated with the Lambda function."
  default = []
}

variable "lambda_vpc_security_group_ids" {
  type = "list"
  description = "A list of security group IDs associated with the Lambda function."
  default = []
}

variable "lambda_logs_policy" {
  description = "Create a policy for the logs. If true, then the logs policy will be create"
  default = true
}

variable "logs_policy" {
  description = "The name of the policy for the logs, if is set, then the logs policy will be created"
  default = false
}

