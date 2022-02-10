variable "root_account_id" {
  type = number
}

variable "account_ids" {
  type = map(string)
}

resource "aws_iam_role" "admin" {
  name = "CloudAdmin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = { "AWS" : "arn:aws:iam::${var.root_account_id}:user/CloudAdmin" }
    }]
  })
}

resource "aws_iam_role_policy" "admin" {
  for_each = var.account_ids

  role = aws_iam_role.admin.id
  name = "AssumeCloudAdminRole${title(each.key)}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "arn:aws:iam::${each.value}:role/CloudAdmin"
    }]
  })
}

resource "aws_iam_policy_attachment" "admin" {
  name       = "CloudAdmin"
  roles      = [aws_iam_role.admin.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "aws_iam_role_admin_arn" {
  value = aws_iam_role.admin.arn
}
