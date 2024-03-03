data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "dns_health_check_function" {
  filename      = "dns_health_check.zip"
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "dns_health_check.lambda_handler"
  runtime       = "python3.9"
}

resource "null_resource" "python_script" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "curl -o dns_health_check.zip https://seal-demo-1303613262.cos.ap-guangzhou.myqcloud.com/dns_health_check.zip"
  }
}
