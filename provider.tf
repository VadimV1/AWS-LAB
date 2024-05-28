provider "aws" {
    region                    = var.region
}

provider "github" {
  token    = var.github_token
}