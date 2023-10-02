provider "aws" {
  profile = "tola004"
  region  = "us-east-1"
}

resource "random_string" "random_username" {
  length  = 8
  special = false
}

resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "!@#*"
}

output "generated_IP" {
  value = aws_instance.splunk_instance.public_ip
}

output "generated_username" {
  value = random_string.random_username.result
}

output "generated_password" {
  value = random_string.password.result
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
  # Wait for up to 5 minutes for SSH to become available
  when    =create  # Run this provisioner during resource creation
  command = <<-EOT
    while ! nc -z -w 5 ${aws_instance.splunk_instance.public_ip} 8089; do
      echo "Waiting for SSH to become available..."
      sleep 5
    done
    echo "SSH is now accessible. Proceeding with the command."
    curl -k -u admin:SPLUNK-${aws_instance.splunk_instance.id} \
        https://${aws_instance.splunk_instance.public_ip}:8089/services/authentication/users -d \
        "name=${random_string.random_username.result}&password=${random_string.password.result}&roles=user"
    
# Create indexs
    echo "Now creating indexs"
    curl -k -u admin:SPLUNK-${aws_instance.splunk_instance.id} \
      "https://${aws_instance.splunk_instance.public_ip}:8089/services/data/indexes" \
      -d "name=my_custom_index" \
      -d "datatype=event" \
      -d "maxTotalDataSizeMB=50000" \
      -d "homePath=\$SPLUNK_DB/main/db" \
      -d "coldPath=\$SPLUNK_DB/main/colddb" \
      -d "thawedPath=\$SPLUNK_DB/main/thaweddb"
      
    echo "Indexs completed"

  EOT
}
}
