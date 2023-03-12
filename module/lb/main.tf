resource "aws_lb" "alb"{
    count = var.type!="network"?1:0
    name = format("%s-%s-%s",var.appname,var.env,"application")
    internal = var.internal
    load_balancer_type = var.type
    security_groups= var.security_group
    subnets = var.subnets
    enable_deletion_protection=false 
    
    /*access_logs{
        bucket=aws_s3_bucket.lb-logs.id
        prefix=var.appname
        enabled= true
    }*/
    tags=merge(var.tags, {Name = format("%s-%s-%s",var.appname,var.env,"ALB")})

    }

    resource "aws_lb" "network"{
    count = var.type=="network"?1:0
    name = format("%s-%s-%s",var.appname,var.env,"network")
    internal = var.internal
    load_balancer_type = var.type
    subnets = var.subnets
    enable_deletion_protection=false 
    tags = merge(var.tags, {Name = format("%s-%s-%s",var.appname,var.env,"NLB")})
    }

    /*resource "aws_s3_bucket" "lb-logs" {
        bucket = "lb_logs-${var.appname}-${var.env}-${random_string.random.id}"
    }

    resource "random_string" "random"{
        length = 5
        special = false
        upper = false 
    }*/

