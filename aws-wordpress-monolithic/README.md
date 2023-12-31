# AWS WordPress Monolithic

- [1. Architetcure Overview](#1-architetcure-overview)
- [2. Technologies](#2-technologies)
  - [2.1. Required](#21-required)
  - [2.2. Used](#22-used)
- [3. Deployment](#3-deployment)
  - [3.1. Create](#31-create)
  - [3.2. Cleanup](#32-cleanup)
- [4. Project Details](#4-project-details)
  - [4.1. Tree Structure](#41-tree-structure)
  - [4.2. Security](#42-security)
  - [4.3. ACME Certificate](#43-acme-certificate)
- [5. Known Issues](#5-known-issues)
- [6. Abbreviations Used in Document](#6-abbreviations-used-in-document)
- [7. Future Work](#7-future-work)

## 1. Architetcure Overview

![Architecture](images/monolithic-wordpress.drawio.png)

As this is the first project for my portfolio I wanted to start simple and form there building on with my experience over the years in IT.

Since WordPress is widely used I wanted to start there, but despite being a simple monolithic architecture the are several services and topics used.

The EC2 instance used Ubuntu as the AMI and to handle configuration management I use Ansible over shell scripts since I find the code more structured and readable. It does however come at a cost of having more files to overview than a simple script file so bear in mind there's no one size fits all.

While it's possible to have the host configuration done through TF `user_data` I wanted to avoid it in this project to later improve the subsequent projects.

Finally, I decided to use NGINX as the web server as a personal preference but an Apache web server could also be used.

## 2. Technologies

### 2.1. Required

- Terraform
- Ansible

### 2.2. Used

- Terraform
  - AWS SG
    - [Terraform Module: Security Group](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest)
  - AWS VPC
    - [Terraform Module: VPC](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
  - AWS EC2
    - Linux Ubuntu
- Ansible
  - NGINX
  - PHP
  - MySQL
  - WordPress

## 3. Deployment

### 3.1. Create

To start the environment first run the TF code, followed by the Ansible playbook.

```shell
terraform init
terraform apply --auto-approve
```

Once the TF code is executed you'll have the Ansible files automatically created for the new EC2 instance with its public IPv4.

```shell
ansible-playbook ansible/main.yaml
```

### 3.2. Cleanup

To cleanup the environment destroy all the resources with TF.

```shell
terraform destroy --auto-approve
```

Upon cleaning up the environment you'll see this warning, but just ignore it.

```shell
Warning: EC2 Default Network ACL (acl-0c8b3acca7cbbea2a) not deleted, removing from state
```

## 4. Project Details

### 4.1. Tree Structure

```shell
tree -I "terraform.tfstate*"
```

```shell
├── README.md
├── acme.tf
├── ansible
│   ├── main.yaml
│   └── roles
│       ├── mysql
│       │   └── tasks
│       │       └── main.yaml
│       ├── nginx
│       │   ├── handlers
│       │   │   └── main.yaml
│       │   └── tasks
│       │       └── main.yaml
│       ├── php
│       │   └── tasks
│       │       └── main.yaml
│       ├── wp-config
│       │   ├── handlers
│       │   │   └── main.yaml
│       │   └── tasks
│       │       └── main.yaml
│       └── wp-install
│           └── tasks
│               └── main.yaml
├── ansible.cfg
├── ansible.tf
├── ansible_inventory.tpl
├── ec2.tf
├── images
├── main.tf
├── outputs.tf
├── providers.tf
├── route53.tf
├── sg.tf
├── terraform.tf
├── terraform.tfvars
├── variables.tf
└── vpc.tf
```

### 4.2. Security

- The Ubuntu UFW is not used as traffic filtering is taken care of with AWS SG.
- In this project, I use SSH key pairs (ED25519) to gain access to the EC2 instance, but later on, I'll avoid this method as there are better ways of handling access to compute nodes.

### 4.3. ACME Certificate

If you're doing development and want to deploy an ACME certificate with your domain, use the staging URL and only when ready switch to production.

In the file `terraform.tfvars` you can use the variable `disable_acme_tls_prod=true` to switch.

## 5. Known Issues

With the ACME certificate, if you switch from staging to production URL or vise-versa nothing will happen so you'll need to destroy all the resources.

If you change the switch for `disable_acme_tls_prod`, and taint the resources for the `acme_registration` and `acme_certificate`, you'll run into this error.

```shell
Error: acme: error: 404 :: POST :: https://acme-staging-v02.api.letsencrypt.org/acme/revoke-cert :: urn:ietf:params:acme:error:malformed :: Certificate from unrecognized issuer
```

From the looks of it recreate all of the resources once you know your staging works, and only then switch to production.

```shell
terraform destroy --auto-approve
terraform apply --auto-approve
```

## 6. Abbreviations Used in Document

| Abbreviation | Expanded                     |
| ------------ | ---------------------------- |
| AMI          | Amazon Machine Images        |
| EC2          | Amazon Elastic Compute Cloud |
| SG           | Security Group               |
| TF           | Terraform                    |
| UFW          | Uncomplicated Firewall       |
| VPC          | Virtual Private Cloud        |

## 7. Future Work

- [ ] Create bastion host
- [ ] Place EC2 in private subnets, not public
- [ ] Enforce SSH into web via bastion only
