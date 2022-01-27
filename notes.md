Object types: 
 1. Providers - defines information about the provider you want to use e.g. AWS. Includes additional information such as login information, region, etc
 2. Resources - defines a things you want to create
 3. Data sources - defines a read-only copy of an already created resource

terraform workflow
 init 
  - Looks for config files within curent working directory and sees if they need any providers. It will download any necessary
  - Creates a state data file if a state backend is not specified 
 plan
  - Looks at the config files and the contents of the state data, and determine the difference between the two
  - Attempts to work out what needs to change to bring the live configuration into the desired state
 apply
  - Executes the changes using the provider plugin, based on the changes required from the planning state
  - If no plan was run before apply, a plan is run as part of the apply
  - If a plan was done earlier and the output was saved to a file, a new plan doesn't need to happen as part of this state

  Variables can be marked as "sensitive" if you don't want them to show up in logs or terminal output. False is the default

  Variables can have default values, which can be used if one is not provided at runtime

  Variable data types:
   - Primitive:
     - Strings, numbers (int and float) and boolean 
   - Collection:
     - List, set, map
     - These are groupings of primitives
     - List is ordered
     - Set is unordered
     - Map is series of K,V pairs
     - Elements must all be of the same data type
   - Structural
     - Tuple, Object
     - Can mix data types in each grouping, which is the main difference to collections
     - Tuples are similar to lists, and Objects are similar to maps

This list is *invalid* because it is mixing primitives within the one grouping
 [1, 2, "three"]

This is the definition of a list of strings for AWS regions
variable "aws_regions" {
    type = list(string)
    description = "Regions in AWS"
    default = ["us-east-1", "ap-southeast-2"]
}

Referencing an element from the above list is done as follows.
var.aws_regions[0] the first element, var.aws_regions[1] for the second

Maps can be used instead of lists to make referencing easier, for example:

variable "preferred_aws_regions" {
    type = map(string)
    description = "Primary and Backup Regions in AWS"
    default = {
        primary = "ap-southeast-2"
        backup = "us-east-1"
    }
}

Two ways to access the data in collection:
var.preferred_aws_regions.primary or var.preferred_aws_regions["primary"]

Locals are variables that are fixed in the configuration and can't take external input
 - Syntax:
  locals {
     key = value
  }
  E.g.
  locals
   company = "test"
   common_tags = {
     environment = "dev"
   }

Accessing is done as follows:
 local.<name_label>
 E.g.
 local.common_tags.environment

Outputs allows you to get information out of terraform (e.g. for using in other modules)
Syntax:
 output "name_label" {
   value = output_value
   description = ""
   sensitive = true|false
 }

 The sensitive keyword can be used to send outputs to other modules but without printing it to the console or log

Validate:
 - After a terraform init, makes sure that the syntax and logic is correct
 - Does not check state
 - No guarantee of deployment
 - Run with "terraform validate"

Using variables:
 - Default value 
 - With the -var argument in the command line
 - With a specified called -var-file
 - Using a default file named terraform.tfvars or terraform.tfvars.json
 - Using a default file named .auto.tfvars or .auto.tfvars.json
 - Using environment variables starting with TF_VAR_

There is an order of preference for variables, with the last evaluated one taking precedence
 - Environment variables
 - terraform.tfvars, if present
 - terraform.tfvars.json, if present
 - Any *.auto.tfvars or *.auto.tfvars.json, if present
 - Any -var and -var-file, if present


For example, if the environment variable TF_VAR_xyz is set and there is also -var="xyz=...", then the command line argument wins

Terraform tf state date
 - JSON format
 - Includes a version (which version of tf state format is used), the terraform version that was used when creating the resources, and a serial which is updated each time the tfstate is changed, lineage is an ID that uniquely identifes the state data (so terraform knows which state to update), outputs for output values, and resources which have been created
  - For data sources, they have the mode "data" in tfstate
  - For managed resources, they have the mode "managed" in tfstate

Show all resources in the TF state:
C:\Users\Luke\code\terraform-associate-study\network>terraform state list
data.aws_ami.ubuntu_latest
data.aws_availability_zones.available
aws_internet_gateway.sydney-igw
aws_key_pair.ec2-developer-keys
aws_route.sydney-ipv4-default-rt
aws_route_table.sydney-rtb
aws_route_table_association.sydney-public-subnet-az1-assoc
aws_route_table_association.sydney-public-subnet-az2-assoc
aws_security_group.sydney-public-web-sg
aws_security_group_rule.sydney-public-web-all-out-rule
aws_security_group_rule.sydney-public-web-http-in-rule
aws_security_group_rule.sydney-public-web-ssh-in-rule
aws_subnet.sydney-private-subnet
aws_subnet.sydney-public-subnet-az1
aws_subnet.sydney-public-subnet-az2
aws_vpc.sydney-vpc

Show specific resource:
C:\Users\Luke\code\terraform-associate-study\network>terraform state show aws_vpc.sydney-vpc
# aws_vpc.sydney-vpc:
resource "aws_vpc" "sydney-vpc" {
    arn                              = "arn:aws:ec2:ap-southeast-2:976570366358:vpc/vpc-0db1096522c535ce3"    assign_generated_ipv6_cidr_block = false
    cidr_block                       = "10.1.0.0/16"
    default_network_acl_id           = "acl-0df2783c97f0a8b21"
    default_route_table_id           = "rtb-0eb6671d95aec8d42"
    default_security_group_id        = "sg-0fe3b8b78ded62dab"
    dhcp_options_id                  = "dopt-f785ca90"
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    enable_dns_hostnames             = false
    enable_dns_support               = true
    id                               = "vpc-0db1096522c535ce3"
    instance_tenancy                 = "default"
    main_route_table_id              = "rtb-0eb6671d95aec8d42"
    owner_id                         = "976570366358"
    tags                             = {
        "Environment"  = "dev"
        "Orchestrator" = "terraform"
    }
    tags_all                         = {
        "Environment"  = "dev"
        "Orchestrator" = "terraform"
    }
}

Moving an item in the state file (e.g. renaming):
C:\Users\Luke\code\terraform-associate-study\network>terraform state mv aws_subnet.sydney-private-subnet aws_subnet.sydney-private-subnet1
Move "aws_subnet.sydney-private-subnet" to "aws_subnet.sydney-private-subnet1"
Successfully moved 1 object(s).
* Note that you will need also change the resource name in the module if you do this

Terraform Taint
 - Deprecated feature now, use terraform apply -replace="<resource_name> instead
 - Informs terraform that a resource is degraded, and then it should be replaced on next apply, even though the 

 Terraform providers
  - A collection of resources and data sources
  - Versioned - can version lock the provider so new features do not break code
  - Three provider sources:
   - Official: Written and maintained by HashiCorp
   - Verified: Written by a third party that has been verified by HashiCorp, and has gone through the Hashi Technology Partner Program
   - Communuty: Written by the community, and not verified by HashiCorp
   - Terraform Providers block format example:

/* Providers */
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" ! Official hashicorp registry
      version = "~> 3.0"
    }
  }
}

provider "aws" {
 ! provider-specific details e.g. region
}

hashicorp/ is shorthand for official documentation

An alias can be added to have multiple instances of the same provider but with different parameters. For example:

provider "aws" {
  shared_credentials_file = ".creds"
  region                  = "ap-southeast-2"
  alias = "sydney"
}

provider "aws" {
  shared_credentials_file = ".creds"
  region                  = "ap-southeast-1"
  alias = "singapore"
}

Then in the VPC definition use the "provider" parameter:
/* Resources */
resource "aws_vpc" "singapore-vpc" {
  provider = aws.singapore
  cidr_block = var.vpc_cidr_block

  tags = local.common_tags
}

resource "aws_vpc" "sydney-vpc" {
  provider = aws.sydney
  cidr_block = var.vpc_cidr_block

  tags = local.common_tags
}

Post-configuration options:
 - Use a resource e.g. resource "file" is the preferred method
 - Pass data e.g. user_data / cloud-init - downside is that terraform has no idea if the script passed or not
 - Use config management software e.g. Ansible
 - Provisioners:
  - Defined as part of a resource, used on creation or destruction
  - If you want to run it independent of a resouirce, you can use the "null" resource
  - Best as a last report, because they are objects created that Terraform does not understand or know about
   - Because the state can't be tracked, they are not idempotent and will be run on each execution (because TF doesn't know if they were successfull or not)
   - Three typoes:
    - File - Copy a file up to the device
    - Local-exec - Run a command on the local machine
    - Remote-exec - Run a command on the remote machine
   - Connection types have to be defined, requiring how to connect to the device e.g. IP, username/password/keys
   - One possible example is to use a file provisioner to copy a file up to the machine, then run it using remote-exec
   - Preferable to use things like Packer to build an AMI to deploy using terraform
  
  Terraform planning
   - Refreshes and inspects state
   - Builds a dependency graph based on the data sources and resrources in the code
   - Compares the dependency graph to the current module to see what needs to changes 
   - Determines which changes are dependent on other things, and works out where things can be parrallelized
   - Uses references to figure out the dependency graphs
   - For example, aws_vpc has no dependenceis, however aws_subnet depends on aws_vpc, therefore terraform waits until aws_vpc is created before creating aws_subnet
    - Sometimes a dependency is not obvious to TF and you need to use the depends_on = [<resource>] parameter.
     - One example is if you use a cloud-init that depends on the contents of an S3 bucket that you are also creating, therefore the aws_instance resource would have an depends_on the creation of the bucket

Looping constructs:
 - count
  - Good for creating resources which are very similar in configuration e.g. aws_instances that are part of an LB target
  - Value of a count is an integer
  - Has a counter to track the current iteration of the loops
  - Bad: Hard to delete resources because deleting a resource would change the index in the count
 - for_each
  - Takes a set or map as a value
  - Good for when resources are significantly different
  - Full access to the values in the set or map that can be used in the resource definition
 - Dynamic blocks
  - Used to create multiple instances of a nested block
  - Map or set

Count example:
 resource "aws_instance" "web_servers" {
   count = 3
   tags = {
     Name = "globo-web-${count.index}
   }
 }

 This will create 3 AWS instances, with the tags:
  - Name = "globl-web-0"
  - Name = "globl-web-1"
  - Name = "globl-web-2"

You can access the specific instance of a resource that has been created as per a count using the syntax:
 <resource_type>.<name_label>[element].attribute 
E.g.
 aws_instance.web_servers[0].id for the first instance

To retreive all instances:
 aws_instance.web_servers[*].id for the first instance

Terraform expressions:
 - Interpolation and heredoc
 - Arihmetic and logical operators
 - Conditional expressions
 - For expressions

Terraform functions:
 - Bult-into the terraform installer
 - func_name(arg1, arg2, arg3)

Common Functions:
 - Numeric e.g. min(42,13,7)
 - String e.g. lower("TACOS")
 - Collection e.g. merge(map1, map2) - e.g. merges two maps
 - IP network e.g. cidrsubnet()
 - File system e.g. file(path) - e.g. reads the contents into a string
 - Type conversion e.g. toset()

 CIDR Block Example (done using Terraform Console)
> cidrsubnet(var.vpc_cidr_block, 8, 0)
"10.1.0.0/24"
> cidrsubnet(var.vpc_cidr_block, 8, 1)
"10.1.1.0/24"

Lookups with default values if value is not found
> lookup(local.common_tags, "Name")
╷
│ Error: Invalid function argument
│
│   on <console-input> line 1:
│   (source code not available)
│
│ Invalid value for "inputMap" parameter: the given object has no attribute "Name".
> lookup(local.common_tags, "Name", "Missing")
"Missing"

E.g. for creating multiple subnets
resource "aws_subnets" "subnets" {
 count = 2
 cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index)

}

Useful for tags (common tags + a unique one per resource)
  tags = merge(local.common_tags, { Name = "Subnet-${each.key}"})

A set of TF files in a directory is called a module:
 - The directory you are working in is called tghe root module
 - Can use child modules (directories)
 - Improves code reuse
 - Remote or local sources, and includes versioning
 - Once a module has been added, use terraform init to download it
 - Module components:
  - Input variables
  - Output values
  - Resources and data sources

Module scoping:
 - Variables must be passed from a parent module to a child module thorugh the use of input variables
 - Child modules has no access to anything in the parent module except those that come from input variables
 - Child modules pass data back to the parent module through output variables

Module syntax:

module "name_label" {
  source = "local_or_remote_source"
  version = "version_expression"

  # input_variable_values
}

Reference a module
module.<name_label>.<output_name>
 - Output values can be of any data type

For Expressions:
 - Input types: list, set , tuple, map, or object
 - Result types: Tuple or object
 - Filtering with if statement

E.g.
# create a tuple
[ for item in items : tuple_element]
# example:
locals {
  toppings = ["cheese, "lettuce", "salsa"]
}
[ for t in local.toppings : "Globlo ${t}" ]

# result =
["Globo cheese", "Globl lettuce", "Globo Salsa"]

# Create an object>
{ for key, value in map : obj_key => obj_value }