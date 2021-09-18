resource "aws_iam_role" "tf-codepipeline-role" {
  name = "tf-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



data "aws_iam_policy_document" "tf-cicd-build-policy" {
    statement {
        sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretmanager:*", "iam:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "tf-cicd-build-policy" {
    name = "tf-cicd-build-policy"
    path = "/"
    description = "Codebuild_policy"
    policy = data.aws_iam_policy_document.tf-cicd-build-policy.json
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codebuild-attachment1" {
    policy_arn = aws_iam_policy.tf-cicd-build-policy.arn
    role       = aws_iam_role.tf-codepipeline-role.id
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codebuild-attachment2" {
    policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
    role       = aws_iam_role.tf-codepipeline-role.id
}