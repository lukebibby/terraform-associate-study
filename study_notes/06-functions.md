# Functions
This document describes some common functions that are supported by Terraform for performing string manipulation, numeric, and subnetting.

## Functions Introduction
Terraform include a number of built-in functions that can be used within the code to manipulate strings, generate UUIDs, creates cryptographic hashes, and generate subnet numbers.


## String functions
We have a Terraform module that creates an S3 bucket using a name provided through an input variable. S3 buckets [require](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html) that name do not include upper case characters. We can use the lower() function to make any string all lower case, as can be seen in the below example.
```
/* Input Variables */
variable "s3_bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
}

/* Storage resources */
resource "aws_s3_bucket" "private-s3-bucket" {
  bucket = lower(var.s3_bucket_name)
  acl    = "private"
}
```

Now when we run Terraform as follows, we will see that my mixed-case input (Testing123) for the S3 bucket name will be normalized to all lower characters (testing123).
```
lbibby@Lukes-MBP infra % terraform plan -var 's3_bucket_name=Testing123'
...

Terraform will perform the following actions:

  # aws_s3_bucket.private-s3-bucket will be created
  + resource "aws_s3_bucket" "private-s3-bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "testing123"
      ...
```

A much nicer way to test out the result of a function given some input is to use the Terraform Console as follows (including a few other examples)

```
lbibby@Lukes-MBP infra % terraform console
> lower("Testing123")
"testing123"
> upper("testing123")
"TESTING123"
> chomp("testing123\n\n")
"testing123"
> join(",", ["user1", "user2", "user3"])
"user1,user2,user3"
> split(",", "user1,user2,user3")
tolist([
  "user1",
  "user2",
  "user3",
])
> strrev("Testing123")
"321gnitseT"
```

## Numeric functions
Using Terraform console again, we can see the use of the basic numeric functions like ```max``` and ```min``` which are pretty self-explanatory: the first finds the largest number in a set, and the second function finds the lowest number in a set.

```
> max(15,12,24)
24
> min(15,12,24)
12
```

One interesting function is the ```parseint``` function which can attempt to make an integer out of a number represented in a string, for a particular number base. A really basic example is as follows, where we get the integer 44 from the string "44".

```
> parseint("44", 10)
44
```

Of course, functions can be chained together such that the output of one function becomes the input for another function. In this example, we make an integer out of the string "-44" and then use the abs() function to make it a positive integer.

```
> abs(parseint("-44",10))
44
```

## IP functions
Here's an interesting piece of code that creates a 10 subnets carved from the VPC cidr block using the cidrsubnet() function. The function takes three arguments:
 - The base prefix (e.g. 10.1.0.0/16)
 - How many additional bits to borrow from the host part of the address (e.g. 8 bits borrowed would mean the subnet would be 24 bits (16 + 8) in length)
 - Which number subnet you want to use. (0 would be the first subnet, 1 would be the second, and so forth).

```
/* Resources */
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "${terraform.workspace}-VPC"
  }
}

resource "aws_subnet" "subnets" {
  count = 10
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  vpc_id     = aws_vpc.vpc.id
}
```

When we run a terraform plan we will see that it will create 10 subnets, with the first subnet starting at 10.1.0.0/24, the next with 10.1.1.0/24, all the way up to 10.1.9.0/24.
```
lbibby@Lukes-MBP infra % terraform plan
aws_vpc.vpc: Refreshing state... [id=vpc-0ee1a523ad63cf104]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_subnet.subnets[0] will be created
  + resource "aws_subnet" "subnets" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = (known after apply)
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.1.0.0/24"
      ...
    }

  # aws_subnet.subnets[1] will be created
  + resource "aws_subnet" "subnets" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = (known after apply)
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.1.1.0/24"
      ...
    }
  ...      

  # aws_subnet.subnets[9] will be created
  + resource "aws_subnet" "subnets" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = (known after apply)
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.1.9.0/24"
      ...
    }

Plan: 10 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

## Other useful functions
Another funtion that is convenient to use is the ```merge()``` function which, as the name suggests, can be used to merge two maps together. A practical example is if you have a map variable for commonly use tags in AWS that you apply to all resources (that support tags), and you also want to add in individual tags specific to the resource. This can be done as follows.

```
/* Local variables */
locals {
  common_tags = {
    Environment  = "${terraform.workspace}"
    Orchestrator = "Terraform"
    Section      = "Corporate Infrastructure"
  }
}

/* Resources */
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"

  tags = merge(local.common_tags, {Name = "VPC"})
}
```

In the above example, the map called common_tags is merged with a newly created inline map which has a single key-value item which is Name = "VPC". This creates a new map that looks as follows.

```
      + tags                             = {
          + "Environment"  = "dev"
          + "Name"         = "VPC"
          + "Orchestrator" = "Terraform"
          + "Section"      = "Corporate Infrastructure"
      }
```
