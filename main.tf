terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Safely read your exported flow JSON from the local filesystem
data "local_file" "flow_json" {
  filename = "${path.module}/flows/GI_Inbound_Main_ucsf.json"
}
resource "aws_connect_instance" "this" {
  identity_management_mode = "CONNECT_MANAGED"  # Built-in Connect user management
  inbound_calls_enabled    = true
  outbound_calls_enabled   = true
  instance_alias           = var.instance_alias
  name                     = var.instance_name

  # Optional: Enable auto-best-practices validation on save
  auto_resolve_best_practices_enabled = true
}
resource "aws_connect_contact_flow" "main_flow" {
  instance_id  = aws_connect_instance.this.id
  name         = var.contact_flow_name
  type         = "CONTACT_FLOW"  # Change only if your flow is a Queue, Whisper, etc.
  content      = data.local_file.flow_json.content
  description  = "Auto-imported via Terraform"
}