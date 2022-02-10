terraform {
  source = "../../../../modules//accounts"
}

include "root" {
  path = find_in_parent_folders()
}