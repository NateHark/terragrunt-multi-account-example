terraform {
  source = "../../../../modules//iam_roles"
}

locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  trusted_account_id = local.common_vars.root_account_id
}