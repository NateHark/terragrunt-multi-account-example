# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment    = "prod"
  account_name   = "Production"
  aws_account_id = <add AWS account ID here>
  aws_profile    = "prod"
}