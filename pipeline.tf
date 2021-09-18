resource "aws_codebuild_project" "tf-plan" {
    name    = "tf-cicd-plan"
    description = "plan stage for terraform"
    service_role = aws_iam_role.tf-codebuild-role.arn

    artifacts {
        type = "CODEPIPELINE"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "hashicorp/terrform:0.14.3"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "SERVICE_ROLE"
        registry_credential {
            credential = var.dockerhub_credentials
            credential_provider = "SECRETS_MANAGER"
        }
    }
    source {
        type = "CODEPIPELINE"
        buildspec = file("buildspec/plan-buildspec.yml")
    }
}


resource "aws_iam_role" "tf-codebuild-role" {
  name = "tf-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



resource "aws_codebuild_project" "tf-apply" {
    name    = "tf-cicd-apply"
    description = "Apply stage for terraform"
    service_role = aws_iam_role.tf-codebuild-role.arn

    artifacts {
        type = "CODEPIPELINE"
    }

    environment {
        compute_type                = "BUILD_GENERAL1_SMALL"
        image                       = "hashicorp/terrform:0.14.3"
        type                        = "LINUX_CONTAINER"
        image_pull_credentials_type = "SERVICE_ROLE"
        registry_credential {
            credential = var.dockerhub_credentials
            credential_provider = "SECRETS_MANAGER"
        }
    }
    source {
        type = "CODEPIPELINE"
        buildspec = file("buildspec/apply-buildspec.yml")
    }
}

resource "aws_codepipeline" "cicd_pipeline" {
    name = "tf-cicd"
    role_arn = aws_iam_role.tf-codepipeline-role.arn

    artifact_store {
        type = "S3"
        location = aws_s3_bucket.codepipeline_artifacts.id
    }
    stage {
        name = "Source"
        action {
            name = "Source"
            category = "Source"
            version = "1"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            output_artifacts = ["tf-code"]
            configuration = {
                FullRepositoryId = "Innocentvijay/aws-cicd-pipelne"
                BranchName = "main"
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }
    stage {
        name = "Plan"
        action {
            name = "Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            version = "1"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "tf-cicd-plan"
            }
        }
    }

    stage {
        name = "Deploy"
        action {
            name = "Deploy"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "tf-cicd-plan"
            }
        }
    }
}
