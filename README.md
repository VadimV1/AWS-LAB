# AWS-LAB
This aim of this project is to provision a complete AWS infrastructure with a RDS instance and to deploy on that infrastructure  a web application that is micro-serviced and has SSL certifictates.
______________________________
# Step 1 - *Route53* + *AWS Certificate Manager*
## Creation of the Domain and SSL certs.

The first and mostly manual step will be to create a domain name with aws **Route53**.
After the creation of the new domain name, AWS will provide a hosted zone for the domain, after which you will need to create a new SSL certificate with ACM you would need to register the new ACM into the domains Route53 records and validate it.

***Note that the process is documented in the **acm.tf** file of the terraform config**

# Step 2 - Creation of the VPC and the network components

After
