resource "aws_lb" "app-intro-alb" {
    name = "app-intro-alb"
    load_balancer_type = "application"
    enable_cross_zone_load_balancing = false
    security_groups = [aws_security_group.allow-https.id,aws_security_group.allow-internal-8k.id,module.vpc.default_security_group_id]
    subnets = module.vpc.public_subnets
}

resource "aws_lb_target_group" "app-intro-tg" {
    name = "app-intro-tg"
    port = 8000
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = module.vpc.vpc_id
    health_check {
      path = "/"
      unhealthy_threshold = 3
      healthy_threshold = 3
    }
}

resource "aws_lb_listener" "app-intro-alb-listener" {
    load_balancer_arn = aws_lb.app-intro-alb.arn
    port = 443
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = "arn:aws:acm:us-east-2:${data.aws_caller_identity.current.account_id}:certificate/4b9c82ec-d633-41ee-9f00-885fe2f8bdba" # Static, because I'm not shifting my DNS provider over to route53.
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.app-intro-tg.arn
    }
}