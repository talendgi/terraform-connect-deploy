variable "region" {
  description = "AWS region for the Amazon Connect instance"
  type        = string
  default     = "us-east-1"
}

variable "instance_alias" {
  description = "Globally unique alias for the Connect instance (lowercase, numbers/hyphens only)"
  type        = string
}

variable "instance_name" {
  description = "Display name for the Connect instance"
  type        = string
  default     = "GI_ucsf_connect"
}

variable "contact_flow_name" {
  description = "Name to assign to the imported contact flow in the Connect console"
  type        = string
  default     = "GI_Inbound_Main_ucsf"
}

# LAMBDA VARIABLES

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_handler" {
  description = "Entry point (e.g., lambda_function.lambda_handler)"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Runtime (e.g., python3.11, nodejs20.x)"
  type        = string
  default     = "python3.11"
}

variable "lambda_zip_path" {
  description = "Path to the deployment ZIP file"
  type        = string
  default     = "./lambda/GI_VoiceBot_Handler.zip"
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "lambda_memory" {
  type    = number
  default = 256
}

variable "lambda_env_vars" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default = {
    CONVERSATION_TABLE_NAME = "PLACEHOLDER_WILL_BE_OVERRIDDEN"
    KNOWLEDGE_BASE_ID       = "PLACEHOLDER_WILL_BE_OVERRIDDEN" 
    MODEL_ID                = "amazon.nova-lite-v1:0"
    RETRIEVAL_MIN_SCORE     = "0.35"
    RETRIEVAL_TOP_K         = "5"
    STRICT_GROUNDING        = "true"
    VOICE_MAX_CHARS         = "650"
  }
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Gi Patient ucsf"
  type        = string
  default     = "GIPatients_ucsf"
}

variable "knowledge_base_id" {
  description = "ID of the existing Bedrock Knowledge Base"
  type        = string
  default     = "YOUR-KB-ID-HERE"  # Replace with actual KB ID
}