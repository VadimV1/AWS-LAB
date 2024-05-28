variable "region" {
  description = "Main region for all resources"
  type        = string
}

variable "domain" {
  description = "The name of the domain"
  type        = string
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the main VPC"
}

variable "public_subnet_1" {
  type        = string
  description = "CIDR block for public subnet 1"
}

variable "public_subnet_2" {
  type        = string
  description = "CIDR block for public subnet 2"
}

variable "private_subnet_1" {
  type        = string
  description = "CIDR block for private subnet 1"
}

variable "private_subnet_2" {
  type        = string
  description = "CIDR block for private subnet 2"
}

variable "availibilty_zone_1" {
  type        = string
  description = "First availibility zone"
}

variable "availibilty_zone_2" {
  type        = string
  description = "First availibility zone"
}

variable "container_frontend_port" {
  description = "Port that needs to be exposed for the frontend service"
}

variable "container_backend_port" {
  description = "Port that needs to be exposed for the backend service"
}    

variable "shared_config_files" {
  description = "Path of your shared config file in .aws folder"
}
  
variable "shared_credentials_files" {
  description = "Path of your shared credentials file in .aws folder"
}

variable "credential_profile" {
  description = "Profile name in your credentials file"
  type        = string
}

variable "backend" {
  description = "Path to the backend app"
  type        = string
}

variable "frontend" {
  description = "Path to frontend app"
  type        = string
}

variable "www_domain" {
  description = "WWW domain name"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_frontend_branch" {
  description = "GitHub repository branch"
  type        = string
}

variable "github_backend_branch" {
  description = "GitHub repository branch"
  type        = string
}

variable "github_token" {
  description = "GitHub token with repo access"
  type        = string
  sensitive   = true
}
