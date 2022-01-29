# Terraform Workspaces
This document describes how to use Terraform workspaces to configure multiple environments from the same source code.

## Workspaces
When resources are created in Teraform, the state of the infrastructure is stored in a special file called Terraform state (tfstate) in the backend that is being used. If the local backend is being used, then the tfstate is stored on the local machine; if an AWS S3 bucket backend is used, then the tfstate will be stored within an S3 bucket. Terraform *workspaces* allows the same source code to generate resources for different environments that have their own unique tfstate stored in the backend. For example, one workspace could be used for dev and another for pre-prod. By default and without any configuration, the *default* workspace is used. This can be seen as follows.

```
lbibby@Lukes-MBP network % terraform workspace show
default
```

The default workspace cannot be deleted.

We can see which workspaces have been created using the ```terraform workspace list``` command.

```
lbibby@Lukes-MBP network % terraform workspace list
* default
```

The * indicates the workspace we are currently on (in my case, default).

We can create and switch to a new workspace using the the ```terraform workspace create``` command as follows.

```
lbibby@Lukes-MBP infra % terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

We can confirm we are on the dev workspace as follows.
```
lbibby@Lukes-MBP infra % terraform workspace list
  default
* dev
```

We use the name of the workspace by referring to ```$terraform.workspace``` in the code. For example, let's say we want to create a VPC with the Name tag based on the workspace name. We can use the following code to achieve this.

```
/* Resources */
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
      Name = "${terraform.workspace}-VPC"
  }
}
```

If we create this VPC in the "dev" workspace, the VPC will be created with the Name tag of dev-VPC, which we can see as follows.
```
lbibby@Lukes-MBP infra % terraform show      
# aws_vpc.vpc:
resource "aws_vpc" "vpc" {
    arn                              = "arn:aws:ec2:ap-southeast-2:XX:vpc/vpc-0ee1a523ad63cf104"
    assign_generated_ipv6_cidr_block = false
    cidr_block                       = "10.1.0.0/16"
    ...
    tags                             = {
        "Name" = "dev-VPC"
    }
    tags_all                         = {
        "Name" = "dev-VPC"
    }
}
```

If we were to create a new workspace for pre-prod called preprod then run a terraform apply on the same code within the preprod workspace, a new VPC would be created with the Name tag of preprod-VPC.

```
lbibby@Lukes-MBP infra % terraform show
# aws_vpc.vpc:
resource "aws_vpc" "vpc" {
    arn                              = "arn:aws:ec2:ap-southeast-2:XX:vpc/vpc-0325b2ccd209cde6c"
    assign_generated_ipv6_cidr_block = false
    cidr_block                       = "10.1.0.0/16"
    ...
    tags                             = {
        "Name" = "preprod-VPC"
    }
    tags_all                         = {
        "Name" = "preprod-VPC"
    }
}
```

As mentioned before, each workspace has it's own tfstate file stored in a new directory called ```terraform.state.d```.

```
lbibby@Lukes-MBP infra % ls -l terraform.tfstate.d/{dev,preprod}
terraform.tfstate.d/dev:
total 8
-rw-r--r--  1 lbibby  x  1739 29 Jan 12:53 terraform.tfstate

terraform.tfstate.d/preprod:
total 8
-rw-r--r--  1 lbibby  x  1747 29 Jan 12:58 terraform.tfstate
```

All terraform commands such as plan, apply, destroy will be performed within the context of the workspace. Below I can destroy the VPC in the preprod environment and this will not affect any of the other workspaces.

```
lbibby@Lukes-MBP infra % terraform destroy 

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_vpc.vpc will be destroyed
  - resource "aws_vpc" "vpc" {
      - arn                              = "arn:aws:ec2:ap-southeast-2:XX:vpc/vpc-0325b2ccd209cde6c" -> null
      - assign_generated_ipv6_cidr_block = false -> null
      - cidr_block                       = "10.1.0.0/16" -> null
      ...
      - tags                             = {
          - "Name" = "preprod-VPC"
        } -> null
      - tags_all                         = {
          - "Name" = "preprod-VPC"
        } -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources in workspace "preprod"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes 

aws_vpc.vpc: Destroying... [id=vpc-0325b2ccd209cde6c]
aws_vpc.vpc: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

And we can confirm that this has not deleted the dev VPC if we switch into that workspace and check the tfstate.

```
lbibby@Lukes-MBP infra % terraform workspace select dev
Switched to workspace "dev".
lbibby@Lukes-MBP infra % terraform show
# aws_vpc.vpc:
resource "aws_vpc" "vpc" {
    arn                              = "arn:aws:ec2:ap-southeast-2:XX:vpc/vpc-0ee1a523ad63cf104"
    assign_generated_ipv6_cidr_block = false
    cidr_block                       = "10.1.0.0/16"
    ...
    tags                             = {
        "Name" = "dev-VPC"
    }
    tags_all                         = {
        "Name" = "dev-VPC"
    }
}
```

Workspaces can be deleted using the following command, noting that the default workspace cannot be deleted.
```
lbibby@Lukes-MBP infra % terraform workspace delete default
cannot delete default state
lbibby@Lukes-MBP infra % terraform workspace delete preprod
Deleted workspace "preprod"!
```

Note that all workspaces must be using the same backend.
