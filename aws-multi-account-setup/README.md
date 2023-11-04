# AWS Multi-Account Setup

- [1. Prerequisite Knowledge](#1-prerequisite-knowledge)
- [2. Overview](#2-overview)
- [3. Management Account](#3-management-account)
  - [3.1. Create Remaining Accounts](#31-create-remaining-accounts)
- [4. Ensure Cross-Account Access](#4-ensure-cross-account-access)
- [5. Facilitate Cross-Account Access from Web-Browser](#5-facilitate-cross-account-access-from-web-browser)
- [5. Facilitate Cross-Account Access from CLI](#5-facilitate-cross-account-access-from-cli)

## 1. Prerequisite Knowledge

It's highly recommended you familiarise yourself with IAM policies, IAM roles (Trusted Identity Policy) and cross-account access before proceeding with this guide.

## 2. Overview

Understand that the account IDs listed here are only for showing, since when you create your own you'll end up with different IDs.

| Account Name | Name Expanded | Email                                  | AWS ID       |
| ------------ | ------------- | -------------------------------------- | ------------ |
| mgt          | Management    | [name@domain.com](name@domain.com)     | 000000000000 |
| shr          | Shared        | [name+1@domain.com](name+1@domain.com) | 111111111111 |
| dev          | Development   | [name+2@domain.com](name+2@domain.com) | 222222222222 |
| acc          | Acceptance    | [name+3@domain.com](name+3@domain.com) | 333333333333 |
| prd          | Production    | [name+4@domain.com](name+4@domain.com) | 444444444444 |

## 3. Management Account

First, since this is your first AWS account you'll need to go through the lengthy process of creating your account.

In this section we'll create an IAM group, admin-user and attach policies for MFA and cross account access between your accounts.

1. Secure the root user.
   - Configure a complex root password with for e.g. 35 characters.
   - Enable MFA.

2. Create IAM admin user with Console and programmatic access credentials (save/note these for later).
   - Configure a complex password with for e.g. 35 characters.
   - Setup MFA.

3. Create an IAM group and palce the new IAM user in the group.

    ```bash
    aws iam create-group --group-name operations
    ```

4. Add the new IAM user admin to the group.

    ```bash
    aws iam add-user-to-group --user-name name --group-name operations
    ``

5. Create cross-account policy and attach the JSON file.

    ```bash
    aws iam create-policy \
    --policy-name cross-account-mgt-to-all \
    --policy-document file://policies/cross-account-mgt-to-all.json
    ```

6. Attach cross-account policy to IAM group.

   ```bash
   aws iam attach-group-policy \
   --group-name operations \
   --policy-arn "arn:aws:iam::000000000000:policy/cross-account-mgt-to-all"
   ```

7. Attach Admin access to group.

    ```bash
    aws iam attach-group-policy \
    --group-name operations \
    --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"
    ```

8. Create MFA enforce policy and attach the JSON file.

    ```bash
    aws iam create-policy \
    --policy-name mfa-enforce-users \
    --policy-document file://policies/mfa-enforce-users.json
    ```

9. Attach MFA enforce policy to IAM group.

    ```bash
    aws iam attach-group-policy \
    --group-name operations \
    --policy-arn "arn:aws:iam::000000000000:policy/mfa-enforce-users"
    ```

10. Verify the IAM group with attached user and polcies we've created earlier.

    ```bash
    aws iam get-group --group-name operations
    aws iam list-attached-group-policies --group-name operations
    ```

By now you've configured the management account and added an admin user as well as means to use cross-account access.

### 3.1. Create Remaining Accounts

By now you've configured the management account, but will need to create the remaining AWS accounts and luckly there are easier ways of creating the subsequent ones compared to the first.

There's a trick to use the same email address with increments instead of having multiple email accounts to manage your AWS accounts. Start by using your email address on the management account, and then when registering other accounts you increment like shown on the table.

| Account Name | Name Expanded | Email                                  |
| ------------ | ------------- | -------------------------------------- |
| mgt          | Management    | [name@domain.com](name@domain.com)     |
| shr          | Shared        | [name+1@domain.com](name+1@domain.com) |
| dev          | Development   | [name+2@domain.com](name+2@domain.com) |
| acc          | Acceptance    | [name+3@domain.com](name+3@domain.com) |
| prd          | Production    | [name+4@domain.com](name+4@domain.com) |

1. Get the root ID which you'll need for subsequent commands.

    ```bash
    aws organizations list-roots --query 'Roots[].Id' --output text
    ```

2. Create two OUs under AWS Organizations.

    ```bash
    aws organizations create-organizational-unit \
    --parent-id OrganizationsRootID \
    --name "operations"

    aws organizations create-organizational-unit \
    --parent-id OrganizationsRootID \
    --name "applications"
    ```

3. Verify your structure.

    ```bash
    aws organizations list-organizational-units-for-parent --parent-id rootID
    ```

4. Create the remaining AWS accounts.

    ```bash
    aws organizations create-account \
    --account-name "shr" \
    --email "name+1@domain.com"

    aws organizations create-account \
    --account-name "dev" \
    --email "name+2@domain.com"

    aws organizations create-account \
    --account-name "acc" \
    --email "name+3@domain.com"

    aws organizations create-account \
    --account-name "prd" \
    --email "name+4@domain.com"
    ```

5. Get the ID for the newly created shr account, and use it in the next command.

    ```bash
    aws organizations list-accounts --query "Accounts[?Name=='shr'].Id" --output text
    ```

6. Get ID of the operations OU, and save it for later.

    ```bash
    aws organizations list-organizational-units-for-parent --parent-id r-zeh6 --query "OrganizationalUnits[?Name=='operations'].Id" --output text
    ```

7. Place mgt and shr under the operations OU together.

    ```bash
    aws organizations move-account \
    --account-id 0000000000000 \
    --source-parent-id OrganizationsRootID \
    --destination-parent-id OperationsOuId

    aws organizations move-account \
    --account-id 111111111111 \
    --source-parent-id OrganizationsRootID \
    --destination-parent-id OperationsOuId
    ```

8. Verify your accounts are under the operations OU.

    ```bash
    aws organizations list-accounts-for-parent --parent-id OperationsOuId
    ```

9. Get ID of the applications OU, and save it for later.

    ```bash
    aws organizations list-organizational-units-for-parent --parent-id r-zeh6 --query "OrganizationalUnits[?Name=='applications'].Id" --output text
    ```

10. Place dev, acc and prd under the applications OU together.

    ```bash
    aws organizations move-account \
    --account-id 222222222222 \
    --source-parent-id OrganizationsRootID \
    --destination-parent-id OperationsOuId

    aws organizations move-account \
    --account-id 333333333333 \
    --source-parent-id OrganizationsRootID \
    --destination-parent-id OperationsOuId

    aws organizations move-account \
    --account-id 444444444444 \
    --source-parent-id OrganizationsRootID \
    --destination-parent-id OperationsOuId
    ```

11. Verify your accounts are under the operations OU.

    ```bash
    aws organizations list-accounts-for-parent --parent-id OperationsOuId
    ```

12. Finally to view all accounts with AWS ID, email and name issue the following command.

    ```bash
    aws organizations list-accounts --query 'Accounts[].{ID:Id, Name:Name, Email:Email}' --output table
    ```

By you've created your accounts, placed them in a structured manner within AWS Organizations for future usage.

## 4. Ensure Cross-Account Access

For this we need to create an IAM role with an identity trusted policy which allows the mgt account to assume whatever IAM policy we attach to it.

Repeat these steps for the AWS account shr, dev, acc and prd.

```bash
aws iam create-role \
--role-name cross-account-from-mgt \
--assume-role-policy-document file://policies/cross-account-from-mgt.json
```

```bash
aws iam attach-role-policy \
--role-name cross-account-from-mgt \
--policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

By now you've created the IAM roles, their trust policies and attached the admin access policy to it.

## 5. Facilitate Cross-Account Access from Web-Browser

In this step we need to make it easier to jump between AWS accounts under your control via the web browser when using the AWS Console.

Since I'm using FireFox I'll be assuming you also do so, but you can also use Chrome or Safari.

1. Download AWS Extend Switch Roles plugin for your browser and use the following sample config.

    ```bash
    ;
    ; AWS Private
    ;

    [organization-private]
    aws_account_id = 000000000000
    aws_account_alias = organisations-mgt

    [private-aws-shr]
    role_arn = arn:aws:iam::1111111111:role/cross-account-from-mgt
    source_profile = organization-private
    color = c7ceec
    region=eu-west-1

    [private-aws-dev]
    role_arn = arn:aws:iam::222222222222:role/cross-account-from-mgt
    source_profile = organization-private
    color = 59f68d
    region=eu-west-1

    [private-aws-acc]
    role_arn = arn:aws:iam::333333333333:role/cross-account-from-mgt
    source_profile = organization-private
    color = f3f89d
    region=eu-west-1

    [private-aws-prd]
    role_arn = arn:aws:iam::444444444444:role/cross-account-from-mgt
    source_profile = organization-private
    color = ff6d67
    region=eu-west-1
    ```

As you see we're using the roles created under all AWS accounts except mgt.

## 5. Facilitate Cross-Account Access from CLI

To automate most of the work when using cross-account in CLI I strongly suggest to use awsume.

1. Download awsume.

2. Configure your .aws/config

    ```bash
    #
    # AWS Private; IAM Users
    #

    [profile private-aws-mgt-name]
    aws_account_id = 000000000000
    mfa_serial = arn:aws:iam::000000000000:mfa/name

    #
    # AWS Private; IAM Roles
    #

    [profile private-aws-shr]
    role_arn = arn:aws:iam::111111111111:role/cross-account-from-mgt
    source_profile = private-aws-mgt-name

    [profile private-aws-dev]
    role_arn = arn:aws:iam::222222222222:role/cross-account-from-mgt
    source_profile = private-aws-mgt-name

    [profile private-aws-acc]
    role_arn = arn:aws:iam::333333333333:role/cross-account-from-mgt
    source_profile = private-aws-mgt-name

    [profile private-aws-prd]
    role_arn = arn:aws:iam::444444444444:role/cross-account-from-mgt
    source_profile = private-aws-mgt-name

    ```

3. Configure your .aws/credentials

    ```bash
    #
    # AWS Private; IAM Users
    #

    [private-aws-mgt-name]
    aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
    aws_secret_access_key = YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY
    cli_pager =
    ```

4. Basic usage of awsume to help you on your way.

    ```bash
    ❯ awsume -l
    Listing...

    ==================================AWS Profiles==================================
    PROFILE                 TYPE  SOURCE                  MFA?  REGION  ACCOUNT
    private-aws-acc         Role  private-aws-mgt-name    No    None    333333333333
    private-aws-dev         Role  private-aws-mgt-name    No    None    222222222222
    private-aws-mgt-name    User  None                    Yes   None    000000000000
    private-aws-prd         Role  private-aws-mgt-name    No    None    444444444444
    private-aws-shr         Role  private-aws-mgt-name    No    None    111111111111
    ```

    ```bash
    ❯ awsume private-aws-shr
    Session token will expire at 2023-11-04 21:32:10
    [private-aws-shr] Role credentials will expire 2023-11-04 12:57:32
    ```

That's it! If you managed to come all this way and solved any potential issues or bugs give yourself a big pat on the shoulder!
