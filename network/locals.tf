/* Locals */
locals {
  common_tags = {
    Environment  = "dev"
    Orchestrator = "terraform"
  }
  default_ipv4_route = "0.0.0.0/0"
  default_ipv6_route = "::/0"
}