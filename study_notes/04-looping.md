# Looping
This document covers the count parameter, and for and for_each expressions

## Count
A [meta-argument](https://www.terraform.io/language/meta-arguments/lifecycle) that defines how many resources you want to create.

Here is a block of code that creates three AWS VPC public subnets using count.

```
resource "aws_subnet" "subnets" {
    vpc_id = aws_vpc.sydney-vpc.id
    map_public_ip_on_launch = "true"
    
    count = 3
}
```

This will create three subnets, referenced as: 
 - ```aws_subnet.subnets[0]```, ```aws_subnet.subnets[1]```, ```aws_subnet.subnets[2]```


Note that it is zero-indexed.

There is a counter during the iteration of creating the resources which can be accessed using ```count.index```

The above code could be extended to add a Name tag to indicate the subnet number as follows:
```
resource "aws_subnet" "subnets" {
    ...
    
    count = 3

    tags = {
        Name = "Subnet-${count-index}
    }
}
```
This would result in the three subnets created earlier having a Name tag of "Subnet-0", "Subnet-1", and Subnet-2".

Deleting a resource that is not at the tail of the list will cause the elements *after* the deleted resource to be moved in the list. If resource [4] was deleted, then the resource previously at index [5] would now be at index [4]. This can cause other resources that depend on the resource previously at index [5] to have issues next terraform run. 

It is also possible to use count as a conditional, for example if count=0 don't create a resource but if count=1 do create the resource.

For example, consider the case where we only want to create a specific AWS resource in a prod environment but not in any other environment (of course there are better ways to do this, it's just an example).
```
variable "is_prod" {
  description = "Flag to determine whether the environment is production"
  type        = bool
  default     = true
}

resource "aws_instance" "ubuntu" {
  count         = var.is_prod ? 1 : 0
  ...
}
```
In the above example, there is a variable called is_prod that is used as a simple check to see whether this code is for production. If it is, the flag is set to true and the AWS instance is created (count 1 resources created); otherwise the flag is false and the resource is not created (count 0 resources created)

Benefits:
 - Simple
 - Works in really old Terraform versions (although if you are using Terraform you have probably already bought into DevOps, IaC, and immutable infrastructure, so why would you be using really old versions anyway?)

Downfalls:
 - Difficult to maintain if there are a lot of additions and removals of the resource utilizing the count

## For_each
Simimlar to count, for_each can be used to determine how many resources to create. Differently to count, it accepts a map or set of strings and creates resources for each item in the map or set. When you use a for_each with a map, you have full access to all items in the map which can be used.

Here is a block of code that creates three AWS VPC public subnets using for_each, and provides a name and CIDR using a map.

```
resource "aws_subnet" "subnets" {
  vpc_id                  = aws_vpc.sydney-vpc.id
  map_public_ip_on_launch = "true"

  for_each = {
    public_subnet1 = {
      name   = "Subnet 1"
      prefix = "10.1.103.0/24"
    }
    public_subnet2 = {
      name   = "Subnet 2"
      prefix = "10.1.104.0/24"
    }
  }
  cidr_block = each.value["prefix"]

  tags = {
    Name = each.value["name"]
  }
}
```

Individual elements within the iteration can be accessed using each.key and each.value. In the above example a map of maps is used (that is, public_subnet1 is a map and public_subnet_2 is also a map). Because of this, the syntax is using parenthesis to access the value in the second map. A simpler example with only a single map is as follows.

```
resource "aws_subnet" "subnets" {
  vpc_id                  = aws_vpc.sydney-vpc.id
  map_public_ip_on_launch = "true"

  for_each = {
    public_subnet1 = "10.1.103.0/24"
    public_subnet2 = "10.1.104.0/24"
  }
  cidr_block = each.value

  tags = {
    Name = each.key
  }
}
```

It is looks cleaner but is less flexible than a map of maps. An even cleaner example would be to use a variable rather than define the map in-line, as follows.

```
variable "subnets" {
  type = map
  default = {
    public_subnet1 = "10.1.103.0/24"
    public_subnet2 = "10.1.104.0/24"
  }
}

resource "aws_subnet" "subnets" {
  vpc_id                  = aws_vpc.sydney-vpc.id
  map_public_ip_on_launch = "true"

  for_each = var.subnets
  cidr_block = each.value

  tags = {
    Name = each.key
  }
}
```

Accessing the individual elements created with a for_each can also be referenced using the name of the map, such as ```aws_subnet.subnets["public_subnet1"]``` and ```aws_subnet.subnets["public_subnet2"]```. If "public_subnet1" is deleted, it has no effect on the "public_subnet2" resource, such as the indexing issue seen using count earlier.

Benefits:
 - Much more flexible than count
 - Easy to reference individual elements by name
 - Can delete and add resources without indexing issues

Note that the use of for_each and count in a resource are mutually exclusive.

## For
A for loop is Terraform is very similar to a Python list comprehension, to iterate over a list of elements, perform some action on those elements, and generate a new list. In Terraform the inputs however can be maps, objects, sets, and the output is determined by the brackets wrapping the for loop. For example, square brackets will produce a list and curly brackets will produce a map. 

The classic example is to take a group of mixed case values and produce a new group with only lower case values. For example:
```
variable "user_names" {
    default = [
        "Admin1",
        "adMin2",
        "ADMIN3"
    ]
}

output "normalized_user_names" {
    value = [for user in var.user_names : lower(user)]
}
```

Running through the Terraform deployment workflow, this would produce the following outputs:
```
...
Outputs:

normalized_user_names = [
  "admin1",
  "admin2",
  "admin3",
]
```

Note that lower() is a built-in Terraform string manipulation function.
