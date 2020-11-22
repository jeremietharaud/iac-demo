vpc_cidr               = "10.0.0.0/16"
azs                    = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
public_subnet_cidr     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
domain_name            = "staging.kojipa.com"
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCQxYXQA4iDngwBfVpk/dGYASX+xZFctCccqsiHB8/Sh7EmI0SjXDNcXsgsm7vWkdnK85OvvExHA6OcMC/xJL6IaT4aCYDVBSkWAhKTaKSSBSVEytzV6CHVpnWqDHQoOm2w44ZxwAmhKFAkkVvoeFP5arxayBq0i26+tV1L6i5zu9o21X5KWXbAiuQwIXlXMwOXjr9DBJU73ag5+y8i5UYR7ICyu/4jYyyFIV3IGKsQTYSe0tzzr16gK3v22n6avjjax2OzNu3l59tobNrSYsdTpdNXHjxHwnyil/WP6EyhYsDPW1BY8w4AhjEu7kFywl2FcF+zKlxP3fJIvasKLMd7 mykey"
tags = {
    "Application" = "IacDemo"
    "Environment" = "staging"
    "Repository" = "https://github.com/jeremietharaud/iac-demo"
}
instance_type = "t2.micro"
cidr_blocks = ["78.192.96.169/32"]
asg_instances_min_size = "1"
asg_instances_max_size = "1"
asg_instances_desired_capacity = "1"
application_port = "80"
force_https = "false"