# SplunkSpinUpWithTf
Spin up splunk on aws with terraform 

# Splunk Enterprise on AWS with Terraform

## Overview

This Terraform script automates the deployment of Splunk Enterprise on AWS. It utilizes the Splunk AWS Marketplace Image and helps you set up the necessary resources in your AWS account.

## Prerequisites

1. **AWS Account:** Ensure you have an AWS account with the necessary permissions.
2. **Terraform Installed:** Make sure you have Terraform installed on your local machine.

## Steps to Deploy

1. **Clone the Repository:**
    ```bash
    git clone [repository_url]
    cd splunk-terraform
    ```

2. **Initialize Terraform:**
    ```bash
    terraform init
    ```

3. **Review and Customize Configuration:**
    - Open `main.tf` and review the configuration.
    - Customize variables like `aws_region`, `instance_type`, etc., based on your requirements.

4. **Deploy Splunk:**
    ```bash
    terraform apply
    ```

5. **Access Splunk:**
    - Once the deployment is complete, access Splunk via the provided public IP.
    - Open your browser and navigate to `http://<public_ip>:8000`.
    - Use the default credentials(https://docs.splunk.com/Documentation/Splunk/latest/Admin/AbouttheSplunkAMI) or the one specified in the Terraform script.

6. **Cleanup (Optional):**
    ```bash
    terraform destroy
    ```

## Configuration Details

- `aws_region`: The AWS region where the resources will be deployed.
- `instance_type`: The type of EC2 instance to be used for Splunk.
- `splunk_ami_id`: The ID of the Splunk AWS Marketplace Image.

## Notes

- Ensure your AWS credentials are configured properly.
- This script assumes you have accepted the terms of the Splunk AWS Marketplace Image.


