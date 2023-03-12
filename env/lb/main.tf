provider "aws" {
    profile = "Terraform"
    region = "us-east-1"
}
module "vpc" {
    source = "../../module/vpc"
    vpc_cidr_block = "192.168.0.0/16"
    env = "dev"
    appname = "student"
    tags ={
        owner ="dev-team"
    }
    public_cidr_block = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
    private_cidr_block = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
    azs = ["us-east-1a" , "us-east-1b" , "us-east-1c"]
}

module "Load-Balancer" {
    source = "../../module/lb"
    env = "dev"
    appname = "Shopify"
    internal="false"
    type="network"
    subnets=module.vpc.public_subnet_ids
    security_group=[module.vpc.security_group]
    tags ={
        owner ="LB"
    }
}