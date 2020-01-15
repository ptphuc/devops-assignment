# Devops-assignment
This repo contains required TF modules and related component . 
VERSION of Terraform using is v 0.12 and above
Each TF can be used separately with variable define and call 

##### Example:
Using aws vpc module to create VPC with custom setting depend on varible

```
#main.tf

module "vpc" {
  source               = "./modules/aws-vpc"
  region               = var.region
  name                 = var.name
  environment          = var.environment
  vpc_cidr_block       = var.vpc_cidr_block
  nat_cidr_blocks      = var.nat_cidr_blocks
  rds_cidr_blocks      = var.rds_cidr_blocks
  app_cidr_blocks      = var.app_cidr_blocks
  rds                  = var.rds
  eip_for_nat_instance = var.eip_for_nat_instance
  use_nat_instance     = var.use_nat_instance
  nat_instance_type    = var.nat_instance_type
  availability_zones   = var.availability_zones
}

```
##### Variable Input follow variables definition in module AWS VPC
```
#aws_vpc/variable.tf

ariable "name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "rds" {
  description = "Whether to create subnet group for RDS"
  default     = false
}
variable "eip_for_nat_instance" {
  description = "Whether to attach EIP to Nat Instances"
  default     = false
}
variable "use_nat_instance" {
  description = "Enable NAT Instance"
  default     = true
}
variable "nat_instance_type" {
  description = "EC2 Instance type used as Nat instance. i.e t2.micro,t3.nano"
  default     = "t2.micro"
}
variable "availability_zones" {
  description = "VPC availability zones"
}
```

## Terraform Modules
+ AWS TFstate bucket
+ AWS VPC
+ AWS Key Pair
+ AWS KMS 
+ AWS EC2 Instance
+ AWS RDS Instance


## Sample web application - Django Polls apps.
  
#### Things used:
- Django version v1.11
- Python v2.7.15 
- Posgresql 10.5 - AWS RDS as Database

#### Tools used:
- Ansible v2.9.0
- Custom inventory script add-on to acquire dynamic resource inventory:
  ansible-dynamic-inventory
  + ec2.py 
  + ec2.ini 
  
Configuration to use ansible-dynamic-inventory scripts:
  You can use this script in one of two ways. The easiest is to use Ansible’s ``-i`` command line option and specify the path to the script after marking it executable:
  ```
  ansible -i ec2.py -u ubuntu us-east-1d -m ping
  ```
  The second option is to copy the script to ``/etc/ansible/hosts`` and ``chmod +x`` it. You must also copy the ec2.ini file to ``/etc/ansible/ec2.ini``. Then you can run ansible as you would normally. This is the way this demo followed.

  **_Note_**: Since we're using dynamic inventory Ansible for this demo ,we don't need to worry about host inventory.
  This is because with dynamic inventory, we can use tag name of resouces as hosts define. 
  
  #### Referrence document:
  https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html#inventory-script-example-aws-ec2
  
  >Tags:
  Each instance can have a variety of key/value pairs associated with it called Tags. The most common tag key is ‘Name’, though anything is possible. Each key/value pair is its own group of instances, again with special characters converted to underscores, in the format tag_KEY_VALUE e.g. tag_Name_Web can be used as is tag_Name_redis-master-001 becomes tag_Name_redis_master_001 tag_aws_cloudformation_logical-id_WebServerGroup becomes tag_aws_cloudformation_logical_id_WebServerGroup

  
  For our case, the EC2 instance is tagged with **Name=devops-test-ec2**

  So the hosts definition in ansible/ec2-instance.yml can be written as:

  ```
  #ansible/ec2-instance.yml

  name: Provision a {{ application_name }} web application
  hosts: tag_Name_devops_test_ec2
  become: true
  ...
  ```
  

### STEPS TO CREATE A DEMO ENViRONMENT WITH DJANGO APP RUNNING:

### 1. Provisioning infrastructure with Terraform
  #### Provide AWS credentials
  - Easiest way is to export export **AWS_ACCESS_KEY_ID** and **AWS_SECRET_ACCESS_KEY** as Environment Variable in the terminal before running Terraform command:
    ```
    export AWS_ACCESS_KEY_ID="xxxxxxxxxxxxxxxx"
    export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxx"
    ```
  - Second way to provide AWS credential in terraform.tfvars with other variables (default file contain all variable in runtime which TF will read) - Be careful to exclude this file in .gitignore to prevent leaking credentials

    ```
    #terraform.tfvars
    ...
    access_key = "my-access-key"
    secret_key = "my-secret-key"
    ...
     ```
  - Third way, use AWS profile. This demo didn't follow that method for simplicity. Find more details with this link -https://www.terraform.io/docs/providers/aws/index.html
  
  ### 2. Prepare variables 
  - Prepare variables in terraform.tfvars (this is used for quick testing purpose and handy only).
    The value can be changed depend of testing purpose/ environment
  ```
    #AWS 
    region      = "ap-southeast-1"

    #Project identifier
    name        = "devops"
    environment = "test"

    #VPC variables
    vpc_cidr_block       = "10.0.0.0/16"
    nat_cidr_blocks      = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    rds_cidr_blocks      = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
    app_cidr_blocks      = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
    rds                  = true
    eip_for_nat_instance = false
    use_nat_instance     = true
    nat_instance_type    = "t2.micro"

    availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]

    #KMS variables
    is_enabled     = true
    description    = "Parameter store kms master key"
    kms_alias_name = "parameter_store_key"

    #RDS
    publicly_accessible = true
    instance_class      = "db.t2.micro"
    engine              = "postgres"
    engine_version      = "10.5"
    db_parameter_group  = "postgres10"
    database_name       = "devops"
    database_user       = "devops"
    database_port       = "5432"
    allocated_storage   = 20
    storage_encrypted   = false
    storage_type        = "standard"
    multi_az            = false
    deletion_protection = false
    apply_immediately   = true

    #AWS Key pair
    key_name = "devops-ec2"
  ```
  ### 3. Run Terraform commands to create resources
    
  To initilize terraform:

    
    terraform init

    
    
  To create plan of which resources will be created by TF:
    
    terraform plan
    
    
  To apply TF plan and start creation process:
  
    terraform apply --auto-approve (this is for no confirmation option only)
  

  ### 4. Ansible step and deploy Django App

  There was local-exec block in main.tf to run Ansible steps right after resources finish creating, it comes with ``triggers {}`` block as well to rerun whenever the changes in resources detected- In this demo, it's ***_public ip_*** of EC2-instance which we use Ansible to apply configure and deploy Django
  
  ```
  # main.tf

  resource "null_resource" "provisioner" {
  depends_on = [module.postgresl-rds,module.ec2_instance]
  triggers = {
    instance_public_ip = module.ec2_instance.public_ip
  }
  provisioner "local-exec" {
    command = "ansible-playbook --private-key ${module.ec2-keypair.private_key_filename} ./ansible/ec2-instance.yml"
  }
  }
  ``` 
  ### 5. Run DJango app
  
  SSH to EC2 instance

    ssh ec2-user@<public_ip> -i path/to/private_key
  Cd to project folder (folder contains manage.py file) and activate virtualenv
    
    cd /home/ec2-user/django-polls-app
    . venv/bin.activate
  Run Django app with setting open to Internet with port 8000

    python manage.py runserver 0:8000
  ### 6. View the Django Polls app
  Open your browser and go to this:
    
    http://<public_ip_of_ec2_instance>:8000

  The website will return result as picture below:

  ![Expected 404 ERROR. Django app has redirected to custom 404 page !](images/404_Error.jpg)


  It's normal result as expected as  Django is not running at production mode with Web Server like Apache or Nginx stand in front.

Continue to access link below to use the admin view of Django Polls App. The admin account to use is created by Ansible Role before (user: admin /default password: qwerty@123 )
  
    http://<public_ip_of_ec2_instance>:8000/admin

![Admin view page of  Django app!](images/admin_login.jpg )

In this view, we can:
- create user for admin site
- create question poll and choice
- modify question, search, filter by date and published status:

![Admin view page of  Django app!](images/admin_interface.jpg)


![Admin view page of  Django app!](/images/polls_interface.jpg)

![Questions/Polls view page of  Django app!](images/question_interface.jpg)

Also, We can try to vote for the polls and see real counting vote in real time by accessing this link:
    
    http://<public_ip_of_ec2_instance>:8000/polls