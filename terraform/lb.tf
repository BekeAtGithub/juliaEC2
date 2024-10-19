# Create a security group for the load balancer
resource "aws_security_group" "lb_sg" {
  name        = "nginx-lb-sg"
  description = "Security group for the NGINX load balancer"
  vpc_id      = module.vpc.vpc_id

  # Ingress rule: Allow HTTP traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-lb-sg"
  }
}

# Create a load balancer
resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = false   # Set to true for internal-only load balancers
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name = "nginx-lb"
  }
}

# Create a target group for the EC2 instances running the app
resource "aws_lb_target_group" "nginx_lb_target" {
  name        = "nginx-lb-targets"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "nginx-lb-target"
  }
}

# Register the EC2 instances as targets for the load balancer
resource "aws_lb_target_group_attachment" "nginx_lb_target_attachment" {
  for_each = {
    app   = aws_instance.app.id
    nginx = aws_instance.nginx.id
  }

  target_group_arn = aws_lb_target_group.nginx_lb_target.arn
  target_id        = each.value
  port             = 8080
}

# Create a listener for the load balancer
resource "aws_lb_listener" "nginx_lb_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_lb_target.arn
  }

  tags = {
    Name = "nginx-lb-listener"
  }
}

# Output the DNS name of the load balancer
output "nginx_lb_dns" {
  description = "The DNS name of the NGINX load balancer"
  value       = aws_lb.nginx_lb.dns_name
}
