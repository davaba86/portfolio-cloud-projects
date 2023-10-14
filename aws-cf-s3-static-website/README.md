# CloudFront with S3 Static Website

## Architecture Overview

![cf-static-website.drawio](file:///Users/davaba/git-repos/portfolio-cloud-projects/aws-cf-with-s3-static-website/images/cf-static-website.drawio.png)

This project builds a CDN fronting a static website hosted in an S3 bucket while using DNS and HTTPS with a custom domain.

## Technologies

### Reqired

- Terraform

### Used

- Terraform
  - AWS ACM
    - [Terraform Module: AWS Certificate Manager (ACM)](https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest)
  - AWS Route53
    - [Terraform Module: AWS Route53](https://registry.terraform.io/modules/terraform-aws-modules/route53/aws/latest)

## Deployment

### Prerequisites

Before starting out be aware of that you need to change the following.

```shell
public_domain = "mechaconsulting.org"
```

### Create

To create the environment run the TF code, and wait a 4-8 minutes for it to be provisioned.

```shell
terraform init
terraform apply --auto-approve
```

### Cleanup

To cleanup the environment destroy all the resources with TF.

```shell
terraform destroy --auto-approve
```

Upon cleaning up the environment you'll see this warning, but just ignore it.

```shell
Warning: EC2 Default Network ACL (acl-0c8b3acca7cbbea2a) not deleted, removing from state
```

## Project Details

### Tree Structure

``````shell
├── README.md
├── acm.tf
├── cf.tf
├── html
│   ├── error.html
│   └── index.html
├── main.tf
├── outputs.tf
├── providers.tf
├── route53.tf
├── s3.tf
├── terraform.tf
├── terraform.tfvars
└── variables.tf
``````

### Security: Custom Header

Since the S3 bucket is considered a custom origin due to its static website configuration we can't use OAC and OAI.

For that reason we have to resort to a custom header which is generated in the CF resource point.

```shell
custom_header {
  name  = "Referer"
  value = random_password.cf_custom_header_password.result
}
```

Further on at the S3 bucket the resource policy checks for this header and only allows that traffic in.

```shell
"Condition" = {
  "StringLike" = {
    "aws:Referer" : random_password.cf_custom_header_password.result
  }
}
```

## Abbreviations Used in Document

| Abbreviation | Expanded  |
| ------------ | --------- |
| TF           | Terraform |

## Future Work

- [ ] !
