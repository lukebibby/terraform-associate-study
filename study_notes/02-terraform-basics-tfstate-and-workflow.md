# Terraform Basics, Workflow, and Terraform State
This document introduces the Terraform workflow, and Terraform state file.

## Terraform Basics
Terraform code is written in a declarative language called HashiCorp Configuration Language (HCL). Terraform code files use the extension .tf. If there are multiple .tf files in a directory, Terraform merges them all together upon execution, however splitting them out into multiple files significantly improves readability.

Terraform code will comprise of the following things:
 - Providers
 - Input variables, local variables, and outputs
 - Data sources
 - Resources

The provider block defines information about the infrastructure provider you want to manage or leverage. "aws" is a provider which allows you to interact with AWS resources and data sources. When "aws" is used within a provider block, it allow you to define additional information about how you want to interact with AWS such as which region you want to provision infrastructure in, and how Terraform can authenticate to your AWS account. Some other providers are:
 - Cisco ACI (ciscoaci) to provision and manage ACI objects (e.g. EPGs) through an APIC
 - Microsoft Azure (azurerm) to provision and manage resources in Azure
 - Random (random), which allows you to generate and use random numbers in your code
 - Vault (vault), which allows you to interact with a HashiCorp Vault server for secrets management

 An example of a provider block using the AWS provider is as follows.
 ```
 /* Providers */
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region                  = "ap-southeast-2"
}

 ```

In the above example, the required_providers block tells where to fetch the provider code from (by default, the public Terraform registry at registry.terraform.io) and what version of the provider code to fetch.

When you run the command ```terraform init``` in the directory with the above code, Terraform will download the provider code into the ```.terraform/providers/``` directory. You can see this as follows.

```
lbibby@Lukes-MBP scratch % terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Installing hashicorp/aws v3.74.0...
- Installed hashicorp/aws v3.74.0 (self-signed, key ID 34365D9472D7468F)

...
```

When you run ```terraform init``` Terraform will download any provider code (aws in the above example), copy any modules into the current working directory, and also initialize the *backend*. By default, the local backend is used which means the terraform state (tfstate) data will be store on the local device. If you were to change the backend from local to AWS S3 for example, you will need to run ```terraform init``` again to re-configure the backend; in this case, the local tfstate file would be uploaded to an S3 bucket as per the new backend configuration.

Locals, input variables and outputs will be discussed in the next document. For now, it is enough to know that there are ways to take in external inputs, use constants, and also send data to the console or into other modules.

The resource block defines the resources you want to create. For example, the following code creates an AWS Virtual Private Cloud (VPC) using Terraform (note that this code is under the provider block discussed earlier)

```
/* Resources */
resource "aws_vpc" "sydney-vpc" {
  cidr_block = "10.1.0.0/16"
}
```

Next we can run run ```terraform plan``` to dry-run the execution. This will Terraform to check the Terraform code against the tfstate file to determine what changes need to be made to bring the infrastructure into the desired state. In my case, I have no resources in the tfstate file so Terraform would have to create the VPC. This can be seen as follows.

```
lbibby@Lukes-MBP scratch % terraform plan

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_vpc.sydney-vpc will be created
  + resource "aws_vpc" "sydney-vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.1.0.0/16"
      + default_network_acl_id               = (known after apply)
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.

...
```

We can go ahead and run ```terraform apply``` to create the infrastructure, which we can see as follows.

```
lbibby@Lukes-MBP scratch % terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_vpc.sydney-vpc will be created
  + resource "aws_vpc" "sydney-vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.1.0.0/16"
      + default_network_acl_id               = (known after apply)
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_vpc.sydney-vpc: Creating...
aws_vpc.sydney-vpc: Creation complete after 1s [id=vpc-04d16486f9a74bb0b]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Note that Terraform gives you one last *out* before going and performing all of the actions needed to bring the infrastructure into the desired state. If you are game, you can use the ```-auto-approve``` option to skip this confirmation which is useful if terraform is being run as part of a CI/CD pipeline where manual input would not be desired.

We can use the ```terraform show``` command to see the resources that have created according to the tfstate file, in a nicely formatted output.

```
lbibby@Lukes-MBP scratch % terraform show
# aws_vpc.sydney-vpc:
resource "aws_vpc" "sydney-vpc" {
    arn                              = "arn:aws:ec2:ap-southeast-2:XX:vpc/vpc-04d16486f9a74bb0b"
    assign_generated_ipv6_cidr_block = false
    cidr_block                       = "10.1.0.0/16"
    default_network_acl_id           = "acl-039c50185e80e8d5b"
    default_route_table_id           = "rtb-0d1b1b8d46645a77a"
    default_security_group_id        = "sg-0b388f6b29eb39fa8"
    dhcp_options_id                  = "dopt-f785ca90"
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    enable_dns_hostnames             = false
    enable_dns_support               = true
    id                               = "vpc-04d16486f9a74bb0b"
    instance_tenancy                 = "default"
    ipv6_netmask_length              = 0
    main_route_table_id              = "rtb-0d1b1b8d46645a77a"
    owner_id                         = "XX"
    tags_all                         = {}
}
```

If you need the output formatted as JSON, you can use the ```-json``` option. You can also use this command to see a nicely formatted version of the plan file generated using the ```terraform plan -out <file_name>``` command.

```
lbibby@Lukes-MBP scratch % terraform show out.tfplan 

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_vpc.sydney-vpc will be updated in-place
  ~ resource "aws_vpc" "sydney-vpc" {
        id                               = "vpc-04d16486f9a74bb0b"
      ~ tags                             = {
          + "Name" = "Sydney-VPC"
        }
      ~ tags_all                         = {
          + "Name" = "Sydney-VPC"
        }
        # (15 unchanged attributes hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

The last component to discuss is data sources, which can be used tell Terraform to pull in data from an external source (defined outside of Terraform), providing a read-only copy of the data that can be used within the code. A good example of this is to pull in the current list of AWS Availability Zones, which can be used in resources such as ```aws_subnet``` to define a subnet as being part of a particular Availability Zone.

## Workflow

## Terraform State (tfstate)
