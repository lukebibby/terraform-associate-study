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

Deleting a resource that is not at the tail of the list will cause the elements *after* the deleted resource to be moved in the list. If resource [4] was deleted, then the resource previously at index [5] would now be at index [4]. This can cause other resources that depend on the resource previously at index [5] to have issues nex terraform run. 

It is also possible to use count as a conditional, for example if count=0 don't create a resource but if count=1 do create the resource.

Benefits:
 - Simple
 - Works in really old Terraform versions (although if you are using Terraform you have probably already bought into DevOps, IaC, and immutable infrastructure, so why would you be using really old versions anyway?)

Downfalls:
 - Difficult to maintain if there are a lot of additions and removals of the resource utilizing the count

## For_each