resource "aws_s3_bucket" "codepipeline_artifacts" {
    bucket = "vijay-aws-cicd-pipeline"
    acl    = "private"
}