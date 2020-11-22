# IAC Demo

### How this repository works
This repository contains HCL code for deploying a small application on AWS. 

The following AWS infrastructure resources are deployed by the stack:

 * VPC
 * Public subnets
 * Internet Gateway
 * Route53 hosted zone
 * ACM certificate for the domain
 * Application load balancer
 * Autoscaling group of EC2 instances with launch configuration.

The application is composed by a nginx running on Linux ubuntu 18.04 and can be deployed on two environments:

 * staging
 * production
  
The folder ```environment``` contains the variable files (.tfvars files) and the backend configuration (.conf files) used by Terraform for deploying these environments

The ```develop``` branch can be used for performing modifications of the stack on staging environment, before being merged on the main branch for deploying the production environment.

## Pre-requisites

 * You need to download [terraform] (https://releases.hashicorp.com/terraform/) in version 0.12.29 (code has not been tested in version >= 0.13)
 * You need to be owner of the DNS domain specified in the ```domain_name``` variable.
 * You need a S3 bucket for storing the tfstate of the stack: *change the .conf files in ```environment``` folder (one per environment) with your own bucket and its region*

**When deploying for the first time** the *production* environment, a certificate is created on ACM with DNS challenge for the validation. **So you will have to add the NS of the AWS Route53 hosted zone into your registrar** before the completion of the deployment (Terraform will wait for the validation of the certificate before adding it on the load balancer).

## How to deploy the stack

 * Initialize your environment with Terraform:
 ```
 terraform init -backend-config=environment/${ENV}_backend.conf -reconfigure
 ```
 * Validate the syntax:
 ```
 terraform validate -var-file=environment/${ENV}.tfvars
 ```
 * Make a plan of the deployment:
 ```
 terraform plan -var-file=environment/${ENV}.tfvars
 ```
 * Apply:
 ```
 terraform apply -var-file=environment/${ENV}.tfvars -auto-approve
 ```

Replace the variable ```ENV``` by either ```staging``` or ```prod```.

## How to modify variables of my environment

Variables are located in `environment` folder. Edit the variables corresponding to your target environment then push the changes according to the previous section.

For a definition of the variables, you can read the description of them in variables.tf file.

## How to customize the application

You can change the user data used for initializing the EC2 instances by modifying the ```user_data.tpl``` file.

## How to connect to the EC2 instances

* Customize the value of the ```public_key``` variable by adding your own public key
* Connect to the public IP of the EC2 instance of your application using SSH and your private key with the user ```ubuntu```.