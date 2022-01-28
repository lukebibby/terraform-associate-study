# Taint and Replace
This document discusses the ```terraform taint``` command and the ```terraform apply -replace``` command.

## The use case for replacing a resource
In some cases, a resource that has been created by Terraform will need to be replaced without the code having for the resource having changed. For example, let's say you deploy an AWS EC2 instance then later SSH into it and accidently delete some files you didn't mean to. You need to re-provision the instnace however you haven't actually changed anything in the code that would make Terraform beleive it actually has actions to perform. 

There are a few options for re-provisioning this resource, the first being the hammer method of simply destroying it then later performing a provision. This can be done by using the resource targetting option with the ```teraform destroy``` command as follows:
```
terraform destroy -target=aws_instance.web_server
```

This will only delete the resource called web_server which is an AWS EC2 instance. After destroying the resource, a second terraform run can be done which provisions the resource and brings the infrastructure back in to line with the desired state.

Interestgingly, destroy is simple an alias for ```terraform apply -destroy```.

A nicer option that can bundle both actions together is simly to use the ```terraform taint``` command as follows.

```
terraform taint aws_instance.web_server
```

When you run ```terraform show``` the resource will show up as tained, meaning Terraform has marked it as unhealthy and needing to be replaced.

```
lbibby@Lukes-MBP scratch % terraform show
# aws_instance.web_server: (tainted)
...
```

Next time Terraform is run, it will replace the tainted resource.

The ```terraform taint``` command is being deprecated according to [this link](https://www.terraform.io/cli/commands/taint).

The new preferred option is to use ```terraform apply -replace=aws_instance.web_server``` which performs the same action as taint, without the need to run a second ```terraform apply``` command like you would have to after tainting a resource with the ```terraform taint``` command.
