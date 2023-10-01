provider "aws" {
  profile = "tola004"
  region  = "us-east-1"
}

resource "aws_security_group" "tola004_sg" {
  name        = "tola004-security-group"
  description = "An tola004 security group for EC2 instances"

  # Ingress rule 1: Allow SSH from specific IP addresses
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule 2: Allow HTTP traffic from anywhere
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Ingress rule 3: Allow Splunk Enterprise Management from anywhere
  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ingress rule 4: Allow Splunk Forwarder listener from anywhere
  ingress {
    from_port   = 9997
    to_port     = 9997
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule 5: Allow SSL/HTTPS traffic from a specific IP
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "splunk_instance" {
ami="ami-0e40787bcd2f11bbb"
  instance_type = "t2.micro"
  key_name      = "tola004keypair"
tags = {
    Name = "SplunkInstance"
  }
vpc_security_group_ids = [aws_security_group.tola004_sg.id]
# Provisioner to wait until the instance is accessible over the internet
provisioner "local-exec" {
  # Wait for up to 5 minutes (60 seconds) for SSH to become available
  when    =create  # Run this provisioner during resource creation
  command = <<-EOT
    while ! nc -z -w 5 ${aws_instance.splunk_instance.public_ip} 8089; do
      echo "Waiting for SSH to become available..."
      sleep 5
    done
    echo "SSH is now accessible. Proceeding with the command."
    python3 my_script.py ${aws_instance.splunk_instance.id} ${aws_instance.splunk_instance.public_ip}
  EOT
}
}

