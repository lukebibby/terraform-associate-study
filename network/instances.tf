/* Module for creating instances */

/* Data Sources */
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-*-amd64-server-*"
    ]
  }
}

/* Resources */
/*
resource "aws_key_pair" "ec2-developer-keys" {
  key_name   = "ec2-keys"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAwyabzIWslC1wAAq21Kw0xRoJHyDSNeAXiC+CL4gQrItN2oq6q5QNK2X8za4SsMNxZC7fH7wvtwmyKZnr8053LeODBpSUVBi1RHfI8uCd/UWHiwHsYEQpT0YoOHKwN1ZbCmyw7PVXy3F1fy3ed6IoMHaDPMDBBJbLLfr4gPjWG5aJ3LaH7Ww+ZwAruEu4nmPiDVOdtzXdsHz/n7/BNctHHSB0gNtf9STyvEQK1HHfX23KU9YCy0SI+VCgwy6ejRycQQ4UxngVJtnR789bvEB9H8Bq0cBHlOda9xk5oIwLYq3fRos0KdxnjHzCiJqIujRTLy/ph9729TtCGxMOqrk1iQ=="
}

resource "aws_instance" "az1_ubuntu" {
  ami           = data.aws_ami.ubuntu_latest.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.sydney-public-subnet-az1.id

  vpc_security_group_ids = [
    aws_security_group.sydney-public-web-sg.id
  ]

  key_name = "ec2-keys"

  user_data = <<EOF
#! /bin/bash
sudo apt update
sudo apt install -y openssh-server
EOF
}
*/