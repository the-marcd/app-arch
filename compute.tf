data "aws_ami" "ecs-ami" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn-ami-*-ecs-optimized"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}



resource "aws_ecs_cluster" "ecs-cluster" {
    name = "ecs-cluster"
}

resource "aws_launch_configuration" "lc" {
    name_prefix = "ecs-lc"
    image_id = data.aws_ami.ecs-ami.image_id
    instance_type = "t3.micro"
    iam_instance_profile = aws_iam_instance_profile.ecs-profile.name
    key_name = "marcd"
    user_data_base64 = base64encode(templatefile("scripts/userdata.sh",
     {
         ecs_cluster_name = aws_ecs_cluster.ecs-cluster.name
     } 
     )
    )
    root_block_device {
      volume_size = 10
      volume_type = "gp2"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "ecs-asg" {
    name = "ecs-asg"
    launch_configuration = aws_launch_configuration.lc.name
    vpc_zone_identifier = module.vpc.private_subnets
    max_size = 4
    min_size = 1 
    desired_capacity = 1 # Would normally be at least 2 for cross-az HA, but demo.
}