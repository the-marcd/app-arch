resource "aws_ecs_cluster" "ecs-cluster" {
    name = "ecs-cluster"
}

resource "aws_ecs_task_definition" "app-intro" {
    family = "app-intro"
    network_mode = "awsvpc"
    container_definitions = <<DEF
    [{
        "name": "app-intro",
        "image": "${aws_ecr_repository.ecr-repo.repository_url}:74ea854e",
        "memory": 256,
        "environment": [
            {
                "name": "DATABASE_URL", 
                "value": "psql://${aws_db_instance.backend-db.username}:${aws_db_instance.backend-db.password}@${aws_db_instance.backend-db.address}/${aws_db_instance.backend-db.name}"
            },
            {
                "name": "SECRET_KEY",
                "value": "#+qyruujr%&tzf+7ma!ig58ml5h0&$el$pz4z4dica4!3qexv%"
            }
        ],
        "portMappings": [
            {
                "containerPort": 8000,
                "hostPort": 8000,
                "protocol": "tcp"
            }
        ]
    }]
    DEF
}

resource "aws_ecs_service" "app-intro-ecs-svc" {
    name = "app-intro-ecs-svc"
    cluster = aws_ecs_cluster.ecs-cluster.name
    task_definition = aws_ecs_task_definition.app-intro.arn
    desired_count = 1
    load_balancer {
      target_group_arn = aws_lb_target_group.app-intro-tg.arn
      container_name = "app-intro"
      container_port = 8000
    }
    network_configuration {
      subnets = module.vpc.private_subnets
      security_groups = [module.vpc.default_security_group_id,aws_security_group.compute-servers.id]
    }
}