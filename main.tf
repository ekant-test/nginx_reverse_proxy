# get the information of the account we are operating in
data "aws_caller_identity" "this" {}

# get information about the region we are operating in
data "aws_region" "this" {}


# create basic settings for the stack
locals {
  # this component belongs to cloudops
  domain = "test"
  # the name of the managed component
  service_name = "test-gateway"
  # the owner of the service
  service_owner = "ekant"
  # the contract for the service
  service_contact = "ekantmate@gmail.com"
  cloud_id   = "test"
  region     = data.aws_region.this.name
  account_id = data.aws_caller_identity.this.account_id
  # the dns zone in which the load balancer name will be managed
  lb_dns_zone = "abc.test.com"
  # the FQDN for the gateway load balancer
  lb_dns_name = "test-alb"

}
