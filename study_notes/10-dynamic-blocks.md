# Dynamic blocks
This document discusses how dynamic blocks can be used to generate repeatable inline configuration within a resource

# Dynamic blocks
Dynamic blocks can be used to generate a set of nested blocks within a resource. For example, inline security group rules can be generated dynamically using the data from a map variable, rather than individually writing out each ```ingress``` and ```egress``` block. 

Let's say we have a map for ingress security group rule and egress security group rules for a particular resource.

```
/* Variables */
variable "ingress_rules" {
  description = "Ingress security group rules"
  type        = map(any)
  default = {
    http_in = {
      proto       = "tcp"
      from_port   = 80
      to_port     = 80
      allowed_ips = ["0.0.0.0/0"]
    }
    https_in = {
      proto       = "tcp"
      from_port   = 443
      to_port     = 443
      allowed_ips = ["0.0.0.0/0"]
    }
    ssh_in = {
      proto       = "tcp"
      from_port   = 22
      to_port     = 22
      allowed_ips = ["0.0.0.0/0"]
    }
  }
}
```
The ```ingress_rules``` variables is a map of maps, with each second level map being a security group rule that includes the protocol, port range, and which addresses the traffic is allowed to come from.

We then define a security group resource as follows, that uses the ```dynamic``` block to generate a set of ingres security group rules based on the map variable ```ingress_rules```.

```
/* Resources */
resource "aws_security_group" "sg" {
  name = "Security groups"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      cidr_blocks = ingress.value["allowed_ips"]
      protocol    = ingress.value["proto"]
    }
  }
}
```

When we run ```terraform plan```, we see the resource to be created expand to include all of the ingress security group rules from our map, as follows.

```
lbibby@Lukes-MBP scratch % terraform plan
aws_vpc.sydney-vpc: Refreshing state... [id=vpc-04d16486f9a74bb0b]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_security_group.sg will be created
  + resource "aws_security_group" "sg" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      ...
    }

  ...

Plan: 2 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

```
