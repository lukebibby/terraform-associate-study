# IaC Basics and Terraform
This document introduces Infrastructure as Code (IaC), Terraform, and what problems Terraform helps solve.

## Infrastructure as Code
IaC allows infrastructure to be managed with source code, allowing the infrastructure that is being managed (such as virtual networks, cloud instances, firewalls, etc) to be repeatably and consistently deployed the same way each time the IaC tool is executed. 

By definining the infrastructure environment in plain-text source code, it can be version controlled like source code which provides better collaboration within teams and better auditing (who changed what), makes self-service easier, makes it easier to create different environments based off the same code (e.g. dev/pre-prod/prod) and also makes it easier to manage infrastructure accross multiple complex platforms (e.g. azure/aws/gcp).

Exampels of IaC tools are Ansible, Puppet, Heat, and Terraform. 

## Terraform
Terraform is an *infrastructure provisioning* IaC tool, meaning it can take care of deploying infrastructure such as instances and virtual networks on a Cloud Service Provider (CSP) like AWS. It is in the same category of IaC tools as Heat, CloudFormation, and so forth.

In a lot of use cases, the responsibiltiy of a Terraform will be to provision the infrastructure using *immutable infrastructure practices* where, for example, an EC2 instance is deployed using a pre-baked (using e.g. Packer) AMI that has all of the software updates applied, apps installed and ready to start on boot. In this case the instance that is deployed using Terraform will not change after it has been deployed. This means that if the pre-baked AMI has been validated to work as intended, Terraform will be deploying infrastructure consistently and repeatably in a known-good state. To change the instance, a new AMI will be created and Terraform will be told to re-provision the instance using the new AMI.

Terraform uses a *declarative* language where the code specifies the desired end state. For example, the following code deploys four AWS instances using Terraform:
```
resource "aws_instance" "web_servers" {
    ...
    count = 4
}
```

When Terraform is run against this code, it will create four instances in AWS. If Terraform was run a second time with no changes to the code, Terraform would indicate that it has nothing to do and would perform no action. If the code was updated to have a count of 5, such as follows:
```
resource "aws_instance" "web_servers" {
    ...
    count = 5
}
```
Then the next time Terraform is run it would determine that the code indicates that there needs to be 5 AWS instances, but there are only 4 currently provisioned, so another instance would be created to bring the live infrastructure into the desired state. If someone was to delete the AWS instance through the management console (i.e. not through Terraform), and Terraform was run again, it would create a new AWS instance to keep the desired state and the actual state in check.
