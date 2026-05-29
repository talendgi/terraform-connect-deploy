output "connect_instance_id" {
  description = "The ID of the newly created Amazon Connect instance"
  value       = aws_connect_instance.this.id
}

output "connect_instance_arn" {
  description = "The ARN of the Amazon Connect instance"
  value       = aws_connect_instance.this.arn
}
output "contact_flow_id" {
  description = "ID of the imported contact flow"
  value       = aws_connect_contact_flow.main_flow.id
}

output "contact_flow_arn" {
  description = "ARN of the imported contact flow"
  value       = aws_connect_contact_flow.main_flow.arn
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda"
  value       = aws_lambda_function.voicebot_handler.function_name
}

output "lambda_function_arn" {
  description = "ARN of the deployed Lambda"
  value       = aws_lambda_function.voicebot_handler.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.GI_patients_ucsf.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.GI_patients_ucsf.arn
}
