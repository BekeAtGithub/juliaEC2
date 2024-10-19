# Define the Route 53 hosted zone (ensure this already exists or create it)
data "aws_route53_zone" "main" {
  name = var.domain_name  # Example: "example.com"
}

# Create a DNS record for the NGINX load balancer
resource "aws_route53_record" "nginx_lb_dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.subdomain  # Example: "app" (for app.example.com)
  type    = "A"

  alias {
    name                   = aws_lb.nginx_lb.dns_name
    zone_id                = aws_lb.nginx_lb.zone_id
    evaluate_target_health = false
  }

  ttl = 300  # Time to live for the DNS record
}

# Output the full DNS name
output "app_dns_name" {
  description = "The full DNS name for the application"
  value       = "${var.subdomain}.${var.domain_name}"
}
