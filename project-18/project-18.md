
# Introducing Backend on S3
- ## Add S3 and DynamoDB resource blocks
  - S3 resource block (should go in root **main.tf** file)
  ```
  resource "aws_s3_bucket" "terraform_state" {
    bucket = "hassan-dev-terraform-bucket"
    # Enable versioning so we can see the full revision history of our state files
    versioning {
      enabled = true
    }
    # Enable server-side encryption by default
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }
  ```
  ** The bucket name should be the bucket created in project 16.
  - Create a DynamoDB resource in root **main.tf** to store the **terraform.tfstate.lock.info** file
  ```
  resource "aws_dynamodb_table" "terraform_locks" {
    name         = "terraform-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"
    attribute {
      name = "LockID"
      type = "S"
    }
  }
  ```
- ## Configure S3 backend in **backend.tf** file
  ```
  terraform {
    backend "s3" {
      bucket         = "hassan-dev-terraform-bucket"
      key            = "global/s3/terraform.tfstate"
      region         = "us-east-1"
      dynamodb_table = "terraform-locks"
      encrypt        = true
    }
  }
  ```
  - Run `Terraform init`
  
    - Terraform state file should appear in the S3 bucket
    ![](./images/s3.PNG)
    - The DynamoDB table should have an entry containing the state file too

  - Add Terraform output
  ```
  output "s3_bucket_arn" {
    value       = aws_s3_bucket.terraform_state.arn
    description = "The ARN of the S3 bucket"
  }
  output "dynamodb_table_name" {
    value       = aws_dynamodb_table.terraform_locks.name
    description = "The name of the DynamoDB table"
  }
  ```
  - Run **terraform apply**
  
  - The S3 bucket should now have versions of the state file
  

# When to use workspaces or directories
To separate environments with significant configuration differences, use a directory structure. Use workspaces for environments that do not greatly deviate from each other, to avoid duplication of your configurations. Try both methods in the sections below to help you understand which will serve your infrastructure best.

# Security refactoring groups with dynamic blocks.
- First add a **locals** block that contains the resources you want to use repeatedly.
  ```
  locals {
    http_ingress_rules = [{
      port = 443
      protocol = "tcp"
    },
    {
      port = 80
      protocol = "tcp"
    }
    ]
    ssh_ingress_rules = [{
      port = 22
      protocol = "tcp"
    }
    ]
  ```
- Next configure your security group resource block like below.
  ```
  resource "aws_security_group" "alb-sg" {
    name   = "alb-sg"
    vpc_id = aws_vpc.main.id
    dynamic "ingress" {
      for_each = local.http_ingress_rules

      content {
        from_port = ingress.value.port
        to_port = ingress.value.port
        protocol = ingress.value.protocol
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    tags = {
        Name = "ALB-SG"
        Environment = var.environment
    } 
  }
  ```
  The **dynamic** block is used to invoke the ingress rules and the **content** block within the dynamic is used to collect attributes for the ingress rules.

# EC2 refactoring with *map* and *lookup* function
- Add the following block to your **variables.tf** file
  ```
  variable "images" {
    type = map
    default = {
        "us-east-1" = "ami-0b0af3577fe5e3532",
        "us-west-1" = "ami-054965c6cd7c6e462"
    }
  }
  ```
  Map is a data structure that stores information in **key**-**value** pairs.
- Replace the **ami** line in the **aws_instance** resource block to use the **lookup** function.
  ```
  resource "aws_instace" "web" {
    ami  = "${lookup(var.images, var.region, "ami-0b0af3577fe5e3532")}
  }
  ```

# Conditional Expressions
We use conditional expressions to make some decisions based on a specific condition. Example:
```
resource "aws_db_instance" "read_replica" {
  count               = var.create_read_replica == true ? 1 : 0
  replicate_source_db = aws_db_instance.this.id
}
```
The **count** variable checks if the variable **create_read_replica** evaluates to **true**. If it does, it sets the value of **count** to 1 else, 0.

# Terraform Modules
- Create a modules directory in your root directory structure
- Inside the modules directory, create directories for required resources like albs, network (VPCs, subnets etc) and autoscaling.
  ```
  ├── modules
      ├── alb
      ├── autoscaling
      ├── compute
      ├── efs
      ├── network
      ├── rds
      └── security
  ```
- Refactor each module to use variables, for all the attributes that need to be configured. See the example below, for creating an instance using modules:
  * main.tf
  ```
  resource "aws_instance" "Bastion" {
    ami                         = var.bastion_ami
    instance_type               = var.instance_type
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = var.security_groups
    key_name                    = aws_key_pair.praise.key_name

    tags = {
      Name = "Bastion"
    }
  }
  ```
  * variables.tf
  ```
  variable "bastion_ami" {
    default = "ami-0c4f7023847b90238"
  }
  variable "security_groups" {
    type = list 
  }
  variable "instance_type" {
    type = string
    default = "t2.micro"
  }
  variable "subnet_id" {
    type = string
  }
  
  * To use outputs from the resources created in your module, create an **outputs.tf** file and output the variables you wish to use.
  ```
  output "instance_ipv4" {
    value = aws_instance.Bastion.public_ip
  }
  ```
  Repeat the same procedure for each of the required modules.

# Creating the Root Module
- In the root directory of your Terraform project, replace the contents of your **main.tf** file to use modules.
  ```
  module "compute" {
    source = "./modules/compute"
    security_groups = [module.network.bastion_sg]
    subnet_id = module.network.public-subnets[0]
  }
  ```
  In the module block, indicate the source (relative or absolute path) to the module you want to use and specify inputs to the required variables you wish to configure, like above. You can pass outputs from other modules as inputs to the variables.
- To use outputs from a module, specify the module name and the name of the output variable described in your output.
  ```
  module.compute.instance_ipv4
  ```
  Create module blocks for each resource you need to create.
![](./images/modules.PNG)
- Final main.tf file:
```
  #############################
 ##creating bucket for s3 backend
 #########################

 resource "aws_s3_bucket" "terraform-state" {
  bucket        = "hassan-dev-terraform-bucket"
  force_destroy = true
 }
 resource "aws_s3_bucket_versioning" "version" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
 }
 resource "aws_s3_bucket_server_side_encryption_configuration" "first" {
  bucket = aws_s3_bucket.terraform-state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
 }

 resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
 }

 ##creating VPC**
 module "VPC" {
  source                              = "./modules/VPC"
  region                              = var.region
  vpc_cidr                            = var.vpc_cidr
  enable_dns_support                  = var.enable_dns_support
  enable_dns_hostnames                = var.enable_dns_hostnames
  enable_classiclink                  = var.enable_classiclink
  preferred_number_of_public_subnets  = var.preferred_number_of_public_subnets
  preferred_number_of_private_subnets = var.preferred_number_of_private_subnets
  private_subnets                     = [for i in range(1, 8, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets                      = [for i in range(2, 5, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
 }

 ##Module for Application Load balancer, this will create Extenal Load balancer and internal load balancer**
 module "ALB" {
  source             = "./modules/ALB"
  name               = "ACS-ext-alb"
  vpc_id             = module.VPC.vpc_id
  public-sg          = module.security.ALB-sg
  private-sg         = module.security.IALB-sg
  public-sbn-1       = module.VPC.public_subnets-1
  public-sbn-2       = module.VPC.public_subnets-2
  private-sbn-1      = module.VPC.private_subnets-1
  private-sbn-2      = module.VPC.private_subnets-2
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
 }

 module "security" {
  source = "./modules/Security"
  vpc_id = module.VPC.vpc_id
 }

 module "AutoScaling" {
  source            = "./modules/Autoscaling"
  ami-web           = var.ami
  ami-bastion       = var.ami
  ami-nginx         = var.ami
  desired_capacity  = 2
  min_size          = 2
  max_size          = 2
  web-sg            = [module.security.web-sg]
  bastion-sg        = [module.security.bastion-sg]
  nginx-sg          = [module.security.nginx-sg]
  wordpress-alb-tgt = module.ALB.wordpress-tgt
  nginx-alb-tgt     = module.ALB.nginx-tgt
  tooling-alb-tgt   = module.ALB.tooling-tgt
  instance_profile  = module.VPC.instance_profile
  public_subnets    = [module.VPC.public_subnets-1, module.VPC.public_subnets-2]
  private_subnets   = [module.VPC.private_subnets-1, module.VPC.private_subnets-2]
  keypair           = var.keypair

 }

 ##Module for Elastic Filesystem; this module will create elastic file system isn the webservers availablity zone and allow traffic from the webservers**

 module "EFS" {
  source       = "./modules/EFS"
  efs-subnet-1 = module.VPC.private_subnets-1
  efs-subnet-2 = module.VPC.private_subnets-2
  efs-sg       = [module.security.datalayer-sg]
  account_no   = var.account_no
 }

 ##RDS module; this module will create the RDS instance in the private subnet**

 module "RDS" {
  source          = "./modules/RDS"
  db-password     = var.master-password
  db-username     = var.master-username
  db-sg           = [module.security.datalayer-sg]
  private_subnets = [module.VPC.private_subnets-3, module.VPC.private_subnets-4]
 }

 The Module creates instances for jenkins, sonarqube abd jfrog
 module "compute" {
  source          = "./modules/compute"
  ami-jenkins     = var.ami
  ami-sonar       = var.ami
  ami-jfrog       = var.ami
  subnets-compute = module.VPC.public_subnets-1
  sg-compute      = [module.security.ALB-sg]
  keypair         = var.keypair
 }
```
![](./images/bucket.PNG)
![](./images/db.PNG)
![](./images/instances.PNG)
![](./images/security-grp.PNG)
Repo containing Terraform files: https://github.com/donhasmo/project-18.git
