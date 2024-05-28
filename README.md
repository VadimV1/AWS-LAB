# AWS-LAB
This aim of this project is to provision a complete AWS infrastructure with a RDS instance and to deploy on that infrastructure  a web application that is micro-serviced and has SSL certifictates.
______________________________
# Step 1 - *Route53* + *AWS Certificate Manager*
## Creation of the Domain and SSL certs.

The first and mostly manual step will be to create a domain name with aws **Route53**.
After the creation of the new domain name, AWS will provide a hosted zone for the domain, after which you will need to create a new SSL certificate with ACM you would need to register the new ACM into the domains Route53 records and validate it.

***Note that the process is documented in the **acm.tf** file of the terraform config**

# Step 2 - Creation of the VPC and the network components
## Creation of the VPC configuration and registering the ALB to the Route53 Records

The VPC configuration consists of two public subnets that will run an ALB on both of them and a NAT gateway(I used one but two are recomended for HA) and an internet gateway, so the VPC would be able to connect to the WWW.

ALB - Will allow us to access specific microservices that are deployed on the private subnets.
NAT gateway - THe private subnets will connect to it and be able to sent requests to the WWW to dependencies etc....

This step consists of configuring a few conponents:

1. IGW
2. ALB
3. NAT gateway
4. NAT elastic ip
5. 2 public subnets
6. 2 private subnets
7. Route table for the public subnets
8. Route table for the private subnets
9. Relevant associations of the routing tables to the subnets

***Note that the process is documented in the **main.tf** file of the terraform config**


