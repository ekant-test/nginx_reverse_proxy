# Nginx Reverse proxy (Provides resolution of application names across VPC and accounts.  All ingress connections to the Environment)

The NGINX web server is configured as a reverse proxy that maps an application's public DNS name to the internal service endpoint in AWS. The gateway is made up of an AWS application load balancer that distributes requests across an autoscaling group of NGINX servers. The NGINX servers are configured as reverse proxy virtual hosts that forward a request with a specific hostname to a configured internal endpoint.

Prequisites :

1) S3 bucket to be created containing the autoscaler.yml file.
2) Required permission to be given on IAM role to download the content of S3 bucket.
3) VPC and subnets created prior to this deployment.
4) DNA/Route 53 access to add the records.
5)


The application DNS to target URL mapping is configured in group_vars/[env].yml. The mapping is called nginx_virtual_hosts and contains a simple hash of name and target attributes.
To release a change to the autoscaler you must:

Terraform apply the changes

Failure to execute all these steps may lead to your autoscaler failing or your changes not being applied.


TODO configure staging gateway DNS
We need to add DNS records manually to the DNS zone. To complete configuration of the gateway, the following DNS record needs to be created in public zone ekant.com:
test.ekant.com CNAME your-publicdns-name-of-oadbalancer.ap-southeast-2.elb.amazonaws.com.


Configure AKAMAI to route https://test.ekant.com requests to https://abc.ekant.com keeping the original host header intact.


Confirm the https://abc.ekant.com endpoint is available.
