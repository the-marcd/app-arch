data "aws_iam_policy_document" "ecr-push" {
    statement {
        actions = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability",
            "ecr:PutImage",
            "ecr:InitiateLayerUpload",
            "ecr:UploadLayerPart",
            "ecr:CompleteLayerUpload"
        ]
        resources = [
            aws_ecr_repository.ecr-repo.arn
        ]
    }
    statement {
        actions = [
            "ecr:GetAuthorizationToken"
        ]
        resources = ["*"]
    }
}

resource "aws_iam_policy" "ecr-push" {
    name = "ecr-push"
    policy = data.aws_iam_policy_document.ecr-push.json
}

data "aws_iam_policy_document" "ecs-rds" {
    statement {
      actions = [
          "rds-db:connect"
      ]
      resources = [
          "${aws_db_instance.backend-db.arn}/dbuser"
      ]
    }
}

resource "aws_iam_policy" "ecs-rds" {
    name = "ecs-rds"
    policy = data.aws_iam_policy_document.ecs-rds.json
}

data "aws_iam_policy_document" "ecs-assume-role" {
    statement {
        actions = ["sts:AssumeRole"]

    principals {
        type = "Service"
        identifiers = ["ecs.amazonaws.com","ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-role" {
    name = "ecs-role"
    assume_role_policy = data.aws_iam_policy_document.ecs-assume-role.json
}

resource "aws_iam_role_policy_attachment" "ecs-role" {
    role = aws_iam_role.ecs-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs-rds" {
    role = aws_iam_role.ecs-role.name
    policy_arn = aws_iam_policy.ecs-rds.arn
}

resource "aws_iam_instance_profile" "ecs-profile" {
    name = "ecs-instance-profile"
    role = aws_iam_role.ecs-role.name
}