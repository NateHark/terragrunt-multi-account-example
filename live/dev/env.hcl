# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment    = "dev"
  account_name   = "Development"
  aws_account_id = <add AWS acccount ID here>
  aws_profile    = "dev"
}