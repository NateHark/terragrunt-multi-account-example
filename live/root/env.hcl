# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  environment    = "root"
  account_name   = "root"
  aws_account_id = <add root/security account ID here>
  aws_profile    = "root"
}