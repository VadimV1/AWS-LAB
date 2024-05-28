#These are the only value that need to be changed on implementation
region                      = "Yuore region"
vpc_cidr                    = "10.0.0.0/16"
domain                      = "vpc name"
public_subnet_1             = "10.0.1.0/24"
public_subnet_2             = "10.0.2.0/24"
private_subnet_1            = "10.0.3.0/24"
private_subnet_2            = "10.0.4.0/24"
availibilty_zone_1          = "il-central-1a"
availibilty_zone_2          = "il-central-1b"
container_frontend_port     = "Desired container port"
container_backend_port      = "Desired container port"
www_domain                  = "Desired domain name"

#Used for CodePipeLine webhook
github_frontend_branch      = "Your Github frontend branch"
github_backend_branch       = "Your Github frontend branch"
github_owner                = "Your Github name"
github_repo                 = "Your Github repo name"
github_token                = "Your github token"

#Used for auto-image push 
shared_config_files         = "/home/v.v/.aws" # Replace with path
shared_credentials_files    = "/home/v.v/.aws" # Replace with path
credential_profile          = "TerraformUser" # Replace with what you named your profile
backend                     = "./backend" # Name of the local backend folder that gets cloned from github
frontend                    = "./frontend" # Name of the local frontend folder that gets cloned from github
