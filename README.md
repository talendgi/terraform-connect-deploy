# Amazon AWS connect , Contact flow, DynamoDB, Lambda with Terraform Deployment

## Prerequisites
- AWS CLI configured with credentials that have `connect:*` and `iam:CreateRole`/`iam:PassRole` permissions
- Terraform >= 1.0 installed
- clear steps in the document: https://docs.google.com/document/d/1uycmWpdwulOAIpBNnjIO3yZsO4OdQIdQ2VzM8Lw0rXI/edit?tab=t.0

## 📁 Project Structure & File Descriptions

```bash
terraform-connect-deploy/
├── main.tf
├── variables.tf
├── outputs.tf
├── .gitignore
└── flows/
    └── contact_flow.json ← Extract your exported flow JSON here
└── lambda/
    └── GIHealthcareLexFulfillment_ucsf.zip ← Extract your exported lambda Function zip here
└── lex/
    └── GIHealthcareBot_ucsf.zip ← Extract your exported lex zip here
```

| File / Directory | Purpose | Key Contents | Why It Enables Safe Handover |
|------------------|---------|--------------|------------------------------|
| `main.tf` | **Core Terraform configuration** that defines the AWS provider, reads local files, and declares the infrastructure to create. | - AWS provider block<br>- `data "local_file"` to read the contact flow JSON<br>- `aws_connect_instance` resource<br>- `aws_connect_contact_flow` resource | Acts as the deployment blueprint. All resource dependencies are explicitly defined, so Terraform creates them in the correct order automatically. |
| `variables.tf` | **Input parameter definitions** that make the configuration reusable across environments. | - `region` (AWS region)<br>- `instance_alias` (globally unique Connect alias)<br>- `instance_name` (display name)<br>- `contact_flow_name` (name shown in Connect console) | No hardcoded values. The receiving user only needs to pass variables via CLI or a `.tfvars` file, keeping the code identical across dev/stage/prod. |
| `outputs.tf` | **Post-deployment return values** printed after a successful `terraform apply`. | - Connect Instance ID & ARN<br>- Contact Flow ID & ARN | Provides immediate verification values. CI/CD pipelines or downstream scripts can parse these outputs without querying AWS manually. |
| `.gitignore` | **Version control exclusion rules** to keep the repository clean and secure. | Ignores `.terraform/`, `*.tfstate*`, `.terraform.lock.hcl`, OS/IDE files | Prevents state file conflicts, avoids exposing local cache or credentials, and ensures every user starts with a fresh, consistent Terraform workspace. |
| `flows/contact_flow.json` | **Source of truth for the contact flow routing logic**. | Raw JSON exported from an existing Amazon Connect instance | Contains the actual call routing, prompts, and branching logic. Terraform reads it as a static data source and injects it into the new instance without modification. |
| `lambda/*.zip` | **Voicebot fulfillment code**. | Python/Node.js Lambda package with DynamoDB write logic + Lex fulfillment | Deployed automatically by Terraform → consistent versioning across environments. |

## Lex Bot Setup (One-Time Manual Step)

This Terraform configuration manages the Amazon Connect instance and contact flow. The Lex V2 bot must be created manually:

1. Go to [Lex V2 Console](https://console.aws.amazon.com/lexv2/home?region=us-east-1)
2. Create bot: `GIHealthcareBot_ucsf` with alias `TestBotAlias_ucsf`
3. Import the bot definition from `lex/GIHealthcareBot.zip` (Actions → Import → Merge)
4. Copy the **Alias ARN** and paste it into `flows/GI_Inbound_Main_ucsf.json` where you see `"AliasArn"`




## Deployment 
```bash
terraform init
terraform plan \
  -var="region=us-east-1" \
  -var="instance_alias=YOUR-GLOBAL-UNIQUE-ALIAS" \
  -var="instance_name=MyConnectInstance" \
  -var="contact_flow_name=GI_Inbound_Main_test"
terraform apply \
  -var="region=<your-region>" \
  -var="instance_alias=<globally-unique-alias>" \
  -var="instance_name=<display-name>" \
  -var="contact_flow_name=<flow-name-in-console>"
```
### example code 
```bash
terraform plan -var="region=us-east-1" -var="instance_alias=giucsf" -var="instance_name=GIucsfConnect"  -var="contact_flow_name=GI_Inbound_Main_ucsf"

terraform apply -var="region=us-east-1" -var="instance_alias=giucsf" -var="instance_name=GIucsfConnect" -var="contact_flow_name=GI_Inbound_Main_ucsf"

```

### using terraform.tfvars
 create a terraform.tfvars file in the root folder , terraform auto-loads .tfvars
 Code example 
 ``` bash
 terraform init
 terraform plan
 terraform apply
 ```

### main.tf File Structure
``` bash 
main.tf
├── terraform block
├── provider block
├── aws_connect_instance.this
├── aws_connect_contact_flow.main_flow
├── aws_iam_role.lambda_exec
├── aws_iam_role_policy_attachment.lambda_basic
├── aws_lambda_function.voicebot_handler
├── aws_iam_role_policy.lambda_dynamodb_access
└── aws_dynamodb_table.conversation_turns
```


terraform plan -var="region=us-east-1" -var="instance_alias=giucsf" -var="instance_name=GIucsfConnect" -var="contact_flow_name=GI_Inbound_Main_ucsf" -var="lex_bot_name=GIHealthcareBot_ucsf" -var="lex_bot_alias_name=TestBotAlias_ucsf"

terraform apply -var="region=us-east-1" -var="instance_alias=giucsf" -var="instance_name=GIucsfConnect" -var="contact_flow_name=GI_Inbound_Main_ucsf" -var="lex_bot_name=GIHealthcareBot_ucsf" -var="lex_bot_alias_name=TestBotAlias_ucsf"
