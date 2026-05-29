terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0" 
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_connect_instance" "this" {
  identity_management_type = "CONNECT_MANAGED"
  instance_alias           = var.instance_alias
  inbound_calls_enabled    = true
  outbound_calls_enabled   = true
}


resource "aws_connect_contact_flow" "main_flow" {
  instance_id = aws_connect_instance.this.id
  name        = var.contact_flow_name
  type        = "CONTACT_FLOW"
  content     = file("${path.module}/flows/GI_Inbound_Main_ucsf.json") 
  description = "Imported via Terraform with dynamic Lex integration"
}

# DYNAMODB TABLE creation

resource "aws_dynamodb_table" "GI_patients_ucsf" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"  # On-demand pricing
  hash_key       = "sessionId"         # Partition key
  range_key      = "turnId"            # Sort key

  # Define all attributes
  attribute {
    name = "sessionId"
    type = "S"  # String
  }

  attribute {
    name = "turnId"
    type = "S" 
  }
  # Point-in-time recovery (recommended for production)
  point_in_time_recovery {
    enabled = true
  }

  # Server-side encryption (default AWS-managed key)
  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "GI Patients ucsf"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Service     = "VoiceBot"
  }
}

# LAMBDA FUNCTION & IAM ROLE

#  IAM Execution Role
resource "aws_iam_role" "lambda_exec" {
  name = "${var.instance_alias}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

#  Attach Basic Logging Permission (CloudWatch)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# OPTIONAL: Add more permissions here if your Lambda needs S3, DynamoDB, etc.
# resource "aws_iam_role_policy" "lambda_access" { ... }

#  The Lambda Function
resource "aws_lambda_function" "voicebot_handler" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  # Use the lambda_env_vars variable
  environment {
    variables = merge(
      var.lambda_env_vars,  # Base defaults from variable
      {
        CONVERSATION_TABLE_NAME = aws_dynamodb_table.GI_patients_ucsf.name  # Dynamic override
        KNOWLEDGE_BASE_ID       = var.knowledge_base_id                        # From variable (static)
      }
    )
  }
   # Ensure DynamoDB is created first
  depends_on = [aws_dynamodb_table.GI_patients_ucsf]
  tags = {
    ManagedBy = "Terraform"
    Service   = "VoiceBot"
  }
}


# LAMBDA PERMISSIONS (Resource-Based Policy)

resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  name = "${var.lambda_function_name}-dynamodb-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.GI_patients_ucsf.arn
        ]
      }
    ]
  })
}
#  Allow Amazon Connect to invoke Lambda
resource "aws_lambda_permission" "connect_invoke" {
  statement_id  = "AllowConnectInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.voicebot_handler.function_name
  principal     = "connect.amazonaws.com"
  source_arn    = aws_connect_instance.this.arn  # your Connect instance
}

# Allow Lex V2 Bot to invoke Lambda
resource "aws_lambda_permission" "lex_invoke" {
  statement_id  = "AllowLexInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.voicebot_handler.function_name
  principal     = "lexv2.amazonaws.com"
  source_arn    = "arn:aws:lex:${var.region}:${data.aws_caller_identity.current.account_id}:bot-alias/*"  # Or specific bot ARN
}

# Need account ID for ARNs
data "aws_caller_identity" "current" {}