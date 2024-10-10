data "aws_partition" "current" {}

### connect GitHub Actions and AWS with OIDC ######################################################
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

data "aws_iam_policy_document" "github_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_oidc.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test = "StringLike"
      # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html#idp_oidc_Create_GitHub
      values   = ["repo:${var.github_org}/${var.github_repo}:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

### Github OIDC role ##############################################################################
resource "aws_iam_role" "github_oidc" {
  name               = "github_oidc_role"
  assume_role_policy = data.aws_iam_policy_document.github_oidc.json
}

resource "aws_iam_role_policy_attachment" "github_oidc" {
  for_each = toset([
    "AmazonEC2FullAccess",
    "AmazonRoute53FullAccess",
    "AmazonS3FullAccess",
    "IAMFullAccess",
    "AmazonVPCFullAccess",
    "AmazonSQSFullAccess",
    "AmazonEventBridgeFullAccess",
    "AmazonDynamoDBFullAccess",
  ])

  role       = aws_iam_role.github_oidc.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/${each.key}"
}

###################################################################################################
# resource "aws_iam_role" "GithubActionsRole" {
#   name = "GithubActionsRole"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "ec2.amazonaws.com" }
#     }]
#   })
# }
