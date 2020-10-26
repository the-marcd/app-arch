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
}

resource "aws_iam_policy" "ecr-push" {
    name = "ecr-push"
    policy = data.aws_iam_policy_document.ecr-push.json
}

data "aws_iam_policy_document" "ec2-assume-role" {
    statement {
        actions = ["sts:AssumeRole"]

    principals {
        type = "AWS"
        identifiers = ["ec2.amazonaws.com"]
    }
    }
}

resource "aws_iam_role" "ecs-role" {
    name = "ecs-role"
    assume_role_policy = data.aws_iam_policy_document.ec2-assume-role.json
}

resource "aws_iam_role_policy_attachment" "ecs-role" {
    role = aws_iam_role.ecs-role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-profile" {
    name = "ecs-instance-profile"
    role = aws_iam_role.ecs-role.name
}