terraform {
  source = "../../../../modules//root_iam_roles"
}

dependencies {
  paths = ["../accounts"]
}

dependency "accounts" {
  config_path = "..//accounts"

  mock_outputs = {
    account_ids = {
      development = 1000001
      production =  1000002
    }
  }
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  account_ids = dependency.accounts.outputs.account_ids
}
