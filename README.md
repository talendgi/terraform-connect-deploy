# Amazon Connect + Contact Flow Terraform Deployment

## Prerequisites
- AWS CLI configured with credentials that have `connect:*` and `iam:CreateRole`/`iam:PassRole` permissions
- Terraform >= 1.0 installed

## 📁 Project Structure & File Descriptions

terraform-connect-deploy/
├── main.tf
├── variables.tf
├── outputs.tf
├── .gitignore
└── flows/
    └── contact_flow.json ← Extract your exported flow JSON here


| File / Directory | Purpose | Key Contents | Why It Enables Safe Handover |
|------------------|---------|--------------|------------------------------|
| `main.tf` | **Core Terraform configuration** that defines the AWS provider, reads local files, and declares the infrastructure to create. | - AWS provider block<br>- `data "local_file"` to read the contact flow JSON<br>- `aws_connect_instance` resource<br>- `aws_connect_contact_flow` resource | Acts as the deployment blueprint. All resource dependencies are explicitly defined, so Terraform creates them in the correct order automatically. |
| `variables.tf` | **Input parameter definitions** that make the configuration reusable across environments. | - `region` (AWS region)<br>- `instance_alias` (globally unique Connect alias)<br>- `instance_name` (display name)<br>- `contact_flow_name` (name shown in Connect console) | No hardcoded values. The receiving user only needs to pass variables via CLI or a `.tfvars` file, keeping the code identical across dev/stage/prod. |
| `outputs.tf` | **Post-deployment return values** printed after a successful `terraform apply`. | - Connect Instance ID & ARN<br>- Contact Flow ID & ARN | Provides immediate verification values. CI/CD pipelines or downstream scripts can parse these outputs without querying AWS manually. |
| `.gitignore` | **Version control exclusion rules** to keep the repository clean and secure. | Ignores `.terraform/`, `*.tfstate*`, `.terraform.lock.hcl`, OS/IDE files | Prevents state file conflicts, avoids exposing local cache or credentials, and ensures every user starts with a fresh, consistent Terraform workspace. |
| `flows/contact_flow.json` | **Source of truth for the contact flow routing logic**. | Raw JSON exported from an existing Amazon Connect instance | Contains the actual call routing, prompts, and branching logic. Terraform reads it as a static data source and injects it into the new instance without modification. |

## Deploy
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
## example code 
```bash
terraform plan -var="region=us-east-1" -var="instance_alias=giucsf" -var="instance_name=GIucsfConnect"  -var="contact_flow_name=GI_Inbound_Main_ucsf"

terraform apply -var="region=us-east-1" -var="instance_alias=giucsf" -var="instance_name=GIucsfConnect" -var="contact_flow_name=GI_Inbound_Main_ucsf"

```

