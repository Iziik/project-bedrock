resource "aws_iam_user" "dev_viewer" {
  name = "bedrock-dev"
  tags = { "role" = "developer-readonly" }
}

resource "aws_iam_access_key" "dev_viewer_key" {
  user = aws_iam_user.dev_viewer.name
}

resource "aws_iam_user_policy_attachment" "dev_attach" {
  user       = aws_iam_user.dev_viewer.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "readonly_policy" {
  user       = aws_iam_user.dev_viewer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSReadOnlyAccess"
}

output "dev_user_access_key_id" {
  value = aws_iam_access_key.dev_viewer_key.id
  sensitive = false
}
output "dev_user_secret" {
  value     = aws_iam_access_key.dev_viewer_key.secret
  sensitive = true
}
