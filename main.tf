locals {
  vpc_id           = "vpc-0d08860aca7550dfd"
  subnet_id        = "subnet-087c5bf95f0a3a77b"
  ssh_user         = "ec2-user"
  key_name         = "demo"
  private_key_path = "~/Downloads/demo.pem"
}

provider "aws" {
  region     = "us-east-1"
  access_key = "YOUR_KEY"
  secret_key = "YOUR_KEY"
}

resource "aws_security_group" "apache" {
  name   = "apache"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "apache" {
  ami                         = "ami-0cff7528ff583bf9a"
  subnet_id                   = "subnet-087c5bf95f0a3a77b"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.apache.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.apache.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.apache.public_ip}, --private-key ${local.private_key_path} httpd.yaml"
  }
}

output "apache_ip" {
  value = aws_instance.apache.public_ip
}
