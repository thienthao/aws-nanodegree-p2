provider "aws" {
  region = var.region
  access_key = "AKIAU2USGA36SNCYC43C"
  secret_key = "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"
}

resource "aws_iam_role" "iam_configuration" {
  name = "iam_configuration"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Sid": "",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

data "archive_file" "deployment" {
	type		= "zip"
	source_file	= "lambda.py"
	output_path = "output.zip"
}


resource "aws_lambda_function" "lambda_function" {
  filename = "output.zip"
  function_name = "lambda_function"
  role          = aws_iam_role.iam_configuration.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  environment {
		variables = {
			greeting = "Hello World!"
		}
	}
}

resource "aws_cloudwatch_event_rule" "schedule_one_minute" {
  name = "schedule_one_minute"
  depends_on = [
    "aws_lambda_function.lambda_function"
  ]
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_function" {
  target_id = "lambda_function" 
  rule = "${aws_cloudwatch_event_rule.schedule_one_minute.name}"
  arn = "${aws_lambda_function.lambda_function.arn}"
}

resource "aws_lambda_permission" "schedule_one_minute" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.schedule_one_minute.arn}"
}

resource "aws_iam_policy" "logger" {
  name        = "logger"
  path        = "/"
  description = "IAM policy for lambda logger."
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],      
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = aws_lambda_function.lambda_function.function_name
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_configuration.name
  policy_arn = "${aws_iam_policy.logger.arn}"
}
