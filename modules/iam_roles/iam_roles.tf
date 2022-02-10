variable "trusted_account_id" {
    type = number
}

resource "aws_iam_role" "admin" {
  name = "CloudAdmin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = { "AWS" : "arn:aws:iam::${var.trusted_account_id}:role/CloudAdmin" }
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