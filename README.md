# Terraform AWS Infrastructure for Expense Manager

This repository contains Terraform configurations to provision AWS infrastructure for an Expense Manager application. The infrastructure includes a Virtual Private Cloud (VPC), Relational Database Service (RDS), and two application components: one for the backend (`app`) and one for a web server (`web server`).

It is a three tier architecture, where nginx is deployed on web tier, application is deployed on app tier, and database is hosted in AWS RDS MySQL.

Design:

Public Load Balancer (Public Subnet) -> Web Tier (Autoscaling Group in Private Subnet) -> Private Load Balancer (Private Subnet) -> App Tier (Autoscaling Group in Private Subnet) -> AWS RDS MySQL (Private Subnet).

## Prerequisites

Before applying the Terraform configurations, make sure you have the following prerequisites:

1. AWS account with appropriate permissions.
2. AWS CLI configured with the required profile.
   In your home directory, create .aws/credentials file and paste the following contents:

```bash
[rd]
aws_access_key_id = <AWS_ACCESS_KEY>
aws_secret_access_key = <AWS_SECRET_KEY>
```

3. Two secrets created in AWS Secret Manager: `expensemanagerdb_username` and `expensemanagerdb_password` to store RDS username and password respectively.
4. Create a S3 bucket for terraform backed. Make sure the bucket name will be used in backend.tf file in each folder.
5. Create a DynamoDB for terraform backend. Make sure the DynamoDB table name will be used in backend.tf in each folder.

Click on `Store a new secret` -> Select `Other type of secret` -> Select `Plaintext` -> Remove existing content and paste the username / password that you are storing.

## Folder Structure

The Terraform configurations are organized into folders based on the components:

- `vpc`: Creates the VPC infrastructure.
- `rds`: Configures the RDS instance for the database.
- `app`: Sets up the backend application component.
- `web-server`: Configures the web server component.

The components should be provisioned in the specified order: `vpc`, `rds`, `app`, `web-server`.

## Usage

1. **VPC Configuration:**

   Navigate to the `vpc` folder and run:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

2. **RDS Configuration:**

   Navigate to the `rds` folder and run:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **App Tier Configuration:**

   Navigate to the `app` folder and run:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Web Server Tier Configuration:**

   Navigate to the `rds` folder and run:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Variables

Each component has its own terraform.tfvars file where you can customize variables like region, instance type, etc.

## Terraform Backend

The Terraform state is stored remotely using an S3 backend. Make sure to configure the backend appropriately in each component's backend.tf file.

## Cleanup

To destroy the created infrastructure, run terraform destroy in each component's directory in reverse order.

```
web-server -> app -> rds -> vpc
```
