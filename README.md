# DevOps One-Click Deployment Assignment

## Architecture

- VPC with 2 public + 2 private subnets
- Public ALB in public subnets
- EC2 instances in private subnets, in an Auto Scaling Group
- NAT Gateway for egress traffic
- Simple Python Flask API on port 8080:
  - `/` returns text
  - `/health` returns `ok`

## Prerequisites

- Terraform v1.x
- AWS account
- AWS credentials configured (`aws configure`)

## Deployment (One Click)

```bash
cd scripts
./deploy.sh

