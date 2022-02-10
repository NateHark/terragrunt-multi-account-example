terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/iam/aws//modules/iam-user?version=4.10.1"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
    name = "CloudAdmin"

    create_iam_user_login_profile = false
    password_reset_required = true
}