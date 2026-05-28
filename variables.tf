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
