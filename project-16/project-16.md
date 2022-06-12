# Prerequisites
- Create an IAM user named **terraform**, ensure the user has only programmatic access and grant the AdmninistratorAccess permissions. 
- Download the secret access key and access key ID CSV file.
- Install boto3 using pip
  ```
  pip install boto3
  ```
- Install AWS CLI and configure programmatic access using
  ```
  aws configure
  ```
  Paste in the access key ID and secret access key when prompted. Leave everything else as default.
- Create an S3 bucket to store Terraform state files.
  ![](./images/bucket.PNG)
- Paste the following python code in a file and run to ensure programmatic access was successfully configured.
  ```py
  import boto3
  s3 = boto3.resource('s3')
  for bucket in s3.buckets.all():
    print(bucket.name)
  ```

# Step 1: VPC, Subnets and Security Groups
## Step 1.1: Create a directory structure and set up Terraform CLI
- Create a folder named PBL and a file called main.tf
- Set up Terraform CLI
  
  $ First, ensure that you are using an administrative shell.
  $ Copy the text specific to your command shell
  - cmd.exe 
  ```
  @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin")
  ```
  $ or powershell.exe 
  ```
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) 
  ```
  $ Paste the copied text into your shell and press Enter.
  Wait a few seconds for the command to complete.
  If you don't see any errors, you are ready to use Chocolatey! Type choco or choco -? now, or see Getting Started for usage instructions.
  
  `choco install terraform`
  
  `terraform -help` to confirm installation of terraform.
## Step 1.2: Create first VPC
- Add AWS as provider and a resource to create a VPC in the main.tf file
  ```
  provider "aws" {
  region = "us-east-1"
  }

  # Create VPC
  resource "aws_vpc" "main" {
    cidr_block                     = "172.16.0.0/16"
    enable_dns_support             = "true"
    enable_dns_hostnames           = "true"
    enable_classiclink             = "false"
    enable_classiclink_dns_support = "false"
  }
  ```
- Download all necessary plugins for Terraform to run
  ```
  terraform init
  ```
  ![](./images/terraform-init.PNG)
- Run 
  ```
  terraform plan
  ```
  to see the changes that will be effected. If you are satisfied with everything, run
  ```
  terraform apply
  ```
## Step 1.3: Create subnet resource
- Add the following block of code to create two VPC subnets
  ```
    # Create public subnets1
    resource "aws_subnet" "public1" {
      vpc_id                     = aws_vpc.main.id
      cidr_block                 = "172.16.0.0/24"
      map_public_ip_on_launch    = true
      availability_zone          = "eu-central-1a"
    }

    # Create public subnet2
    resource "aws_subnet" "public2" {
      vpc_id                     = aws_vpc.main.id
      cidr_block                 = "172.16.1.0/24"
      map_public_ip_on_launch    = true
      availability_zone          = "eu-central-1b"
    }
- Run
  ```
  terraform plan
  terraform apply
  ```
- Destroy the current infrastructure with
  ```
  terraform destroy
  ```
  Type yes when prompted
  ![](./images/destroy.PNG)
# Step 2: Fixing limitations by code refactoring
## Step 2.1: Fixing hard coded values
- Adding the following block to the main.tf file
  ```
    variable "region" {
        default = "us-east-1"
    }

    variable "vpc_cidr" {
        default = "172.16.0.0/16"
    }

    variable "enable_dns_support" {
        default = "true"
    }

    variable "enable_dns_hostnames" {
        default ="true" 
    }

    variable "enable_classiclink" {
        default = "false"
    }

    variable "enable_classiclink_dns_support" {
        default = "false"
    }

    provider "aws" {
    region = var.region
    }

    # Create VPC
    resource "aws_vpc" "main" {
    cidr_block                     = var.vpc_cidr
    enable_dns_support             = var.enable_dns_support 
    enable_dns_hostnames           = var.enable_dns_support
    enable_classiclink             = var.enable_classiclink
    enable_classiclink_dns_support = var.enable_classiclink

    }
## Step 2.2: Fixing multiple resource blocks
- Use Terraform **data sources** to fetch list of availability zones from AWS
  ```
  # Get list of availability zones
  data "aws_availability_zones" "available" {
        state = "available"
  }
  ```
- To make use of the new data resource, add **count** to the subnet block
  ```
  # Create public subnet1
  resource "aws_subnet" "public" { 
        count                   = 2
        vpc_id                  = aws_vpc.main.id
        cidr_block              = "172.16.1.0/24"
        map_public_ip_on_launch = true
        availability_zone       = data.aws_availability_zones.available.names[count.index]
        }
- Make cidr_block dynamic
  ```
    # Create public subnet1
    resource "aws_subnet" "public" { 
        count                   = 2
        vpc_id                  = aws_vpc.main.id
        cidr_block              = cidrsubnet(var.vpc_cidr, 4 , count.index)
        map_public_ip_on_launch = true
        availability_zone       = data.aws_availability_zones.available.names[count.index]
    }
  ```
  * You can experiment with the cidrsubnet function in the terraform console by typing **terraform console** in the terminal
## Step 2.3: Remove hard coded count value
- Introduce the **length()** function which returns the length of a given list, map or string. Update the subnet resource block like so
  ```
  # Create public subnet1
    resource "aws_subnet" "public" { 
        count                   = length(data.aws_availability_zones.available.names)
        vpc_id                  = aws_vpc.main.id
        cidr_block              = cidrsubnet(var.vpc_cidr, 4 , count.index)
        map_public_ip_on_launch = true
        availability_zone       = data.aws_availability_zones.available.names[count.index]
    }
- Update the count argument with a condition
  ```
  # Create public subnets
  resource "aws_subnet" "public" {
    count  = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets   
    vpc_id = aws_vpc.main.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 4 , count.index)
    map_public_ip_on_launch = true
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    }
    ```

    * Try changing the *preferred_number_of_public_subnets* to null to see how the condition works
    ![](./images/null.PNG)
# Step 3: Introducing variables.tf and terraform.tfvars
## Step 3.1: Restructure directory tree
- Create two files, one named variables.tf and the other terraform.tfvars
- Paste in the following block in the variables.tf file
  ```
  variable "region" {
      default = "us-east-1"
  }

  variable "vpc_cidr" {
    default = "172.16.0.0/16"
  }

  variable "enable_dns_support" {
    default = "true"
  }

  variable "enable_dns_hostnames" {
    default ="true" 
  }

  variable "enable_classiclink" {
    default = "false"
  }

  variable "enable_classiclink_dns_support" {
    default = "false"
  }

  variable "preferred_number_of_public_subnets" {
      default = null
  }
  ```
  and the following in the terraform.tfvars file
  ```
  region = "eu-central-1"

  vpc_cidr = "172.16.0.0/16" 

  enable_dns_support = "true" 

  enable_dns_hostnames = "true"  

  enable_classiclink = "false" 

  enable_classiclink_dns_support = "false" 

  preferred_number_of_public_subnets = 2
  ```
  Your directory structure should look like this:
  ```
  .
  ├── main.tf
  ├── terraform.tfstate
  ├── terraform.tfstate.backup
  ├── terraform.tfvars
  └── variables.tf

  0 directories, 5 files
  ```
  Run **terraform plan** and ensure everything runs successfully.
  ![](./images/terraform-plan-last.PNG)
  ![](./images/created-subnets.PNG)
  ![](./images/created-vpc.PNG)
