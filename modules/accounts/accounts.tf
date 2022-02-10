variable "aws_organization_unit_id" {
    type = string
}

variable "environments" {
    type = map(object({name = string, short_name = string, owner_email = string}))
}

resource "aws_organizations_account" "account" {
    for_each = var.environments

    name = each.value.name
    email = each.value.owner_email
    parent_id = var.aws_organization_unit_id

    tags = {
        Name = each.value.name
    }
}

output "account_ids" {
    value = {
        for k, v in aws_organizations_account.account : k => v.id
    }
}