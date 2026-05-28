terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0" # ✅ Pinned version with full Lex V2 support
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
  depends_on  = [aws_lexv2_bot_alias.this]
}