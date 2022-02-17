# terragrunt-multi-account-example

This repository provides a minimalist example of multi-account, multi-region AWS infrastructure with [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/).

# Repository Structure
```bash
|-- live
|   |-- <env>                # Logical environments: dev, staging, prod
|   |-- env.hcl              # Configuration values specific to the logical environment
|   |   |-- <region>         # AWS region. Shared Terragrunt configuration at the region level is defined in subfolders
|   |   |-- region.hcl       # Configuration values specific to the AWS region
|   |   |-- apps             # Application-specific Terragrunt configuration defined in subfolders
|   |-- modules              # General Terraform modules defined as subfolders
|   |   |-- apps             # Application-specific Terraform modules
|-- .gitignore
|-- common_vars.yaml         # Common variables that are not specific to any logical environment, region, or app
|-- terragrunt.hcl           # The root Terragrunt configuration 
```

# Prerequisites
[Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli), [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/), and the AWS CLI are installed and configured.

# Assumptions
* Each logical environment will exist in a separate AWS account
* All AWS accounts will exist in the same [organization](https://aws.amazon.com/organizations/)
* The root account in the organization will contain all general IAM users
* IAM role assumption will be used to access environment-specific accounts

# Initial Setup & Configuration
Some initial setup is required before you will be able to create the logical accounts defined in this repository.
Placeholder configuration values have been provided in certain configuration files which will need to be replaced as you go.

## Create Root Account and Organization
1. Create a new AWS account and organization via the AWS console, or use an existing root account and organization if desired
1. Add the root account ID to the `root_account_id` property in `common_vars.yaml`
1. Add the organization ID to the `aws_organization_unit_id` property in `common_vars.yaml`
1. Add the root account ID to the `aws_account_id` property in `root/env.hcl`
1. Create a new IAM user with administrative privileges in the root account. Generate access keys for this user and configure the AWS CLI by setting the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` variables, or adding the the credentials to `~/.aws/credentials` as follows:

    ```bash
    [default]
    aws_access_key_id = <add key here>
    aws_secret_access_key = <add secret here>
    ```
1. Run the following commands to create all neccessary resources; accounts, IAM users, and IAM roles in the root account

    ```bash
    $ cd live/root
    $ terragrunt run-all plan   # This should run without error and produce a summary of the changes that will be made
    $ terragrunt run-all apply  # This will apply the changes
1. Take note of the IDs for the new AWS accounts emitted as Terraform outputs and add them to the `aws_account_id` properties in `live/dev/env.hcl` and `live/prod/env.hcl` respectively

## Create IAM Roles in Child Accounts
At this point, we'll manually create access keys for the root user in the `dev` and `prod` accounts.
We'll use these credentials temporarily in order to create IAM roles in each account that the admin user in the root account can assume.
After we're done creating the IAM roles, these credentials can be deactivated.

1. Create access keys for the root user in the `dev` and `prod` accounts
1. Add these keys to `~/.aws/credentials` as follows. The profile names must match the value of `aws_profile` in `env.hcl`

    ```bash
    [dev]
    aws_access_key_id = <add key here>
    aws_secret_access_key = <add secret here>

    [prod]
    aws_access_key_id = <add key here>
    aws_secret_access_key = <add secret here>
    ```
1. Run the following commands to create IAM roles in the `dev` account

    ```bash
    $ cd `live/dev`
    $ terragrunt run-all plan   # This should run without error and produce a summary of the changes that will be made
    $ terragrunt run-all apply  # This will apply the changes
    ```

1. Repeat for the `prod` account

    ```bash
    $ cd `live/prod`
    $ terragrunt run-all plan   # This should run without error and produce a summary of the changes that will be made
    $ terragrunt run-all apply  # This will apply the changes
    ```

## Reconfigure AWS CLI Credentials
We are now done with the initial account bootstrap and can reconfigure `~/.aws/credentials` to use our new roles.

```bash
# CloudAdmin IAM user in root account
[default]
aws_access_key_id = <add key here>
aws_secret_access_key = <add secret here>

# CloudAmin role in root account
[root]
role_arn = arn:aws:iam::<add root account ID here>:role/CloudAdmin
source_profile = default

# CloudAdmin role in prod account
[prod]
role_arn = arn:aws:iam::<add prod account ID here>:role/CloudAdmin
source_profile = root

# CloudAdmin role in dev account
[dev]
role_arn = arn:aws:iam::<add dev account ID here>:role/CloudAdmin
source_profile = root
```

## Verify Access to Each Account
The following steps can be used to verify access to each account.

```bash
$ unset AWS_ACCESS_KEY_ID       # Clear any configured value to prevent it from interfering with the test 
$ unset AWS_SECRET_ACCESS_KEY   # Clear any configured value to prevent it from interfering with the test 
$ unset AWS_PROFILE             # Configured the CLI to use the default profile

$ aws sts get-caller-identity   # Expect this to be the CloudAdmin user in the root account. Example output below
{
    "UserId": "<user ID>",
    "Account": "<root account ID>",
    "Arn": "arn:aws:iam::<root account ID>:user/CloudAdmin"
}

$ export AWS_PROFILE=root
$ aws sts get-caller-identity   # Expect you are now assuming the CloudAdmin role in the root account
{
    "UserId": "<user ID>"
    "Account": "<root account id>",
    "Arn": "arn:aws:sts::<root account ID>:assumed-role/CloudAdmin/botocore-session-1644219690"
}
$ aws s3 ls                     # You should see your Terraform state bucket listed in the output. Example below:
<YYYY-MM-DD HH:MM:SS> <unique bucket prefix>-root-us-west-2-terraform-state

$ export AWS_PROFILE=dev
$ aws sts get-caller-identity   # Expect you are now assuming the CloudAdmin role in the dev account
{
    "UserId": "<user ID>",
    "Account": "<dev account ID>",
    "Arn": "arn:aws:sts::<dev account ID>:assumed-role/CloudAdmin/botocore-session-1644219893"
}
$ aws s3 ls                     # You should see your Terraform state bucket listed in the output. Example below:
<YYYY-MM-DD HH:MM:SS> <unique bucket prefix>-dev-us-west-2-terraform-state

$ export AWS_PROFILE=prod
$ aws sts get-caller-identity   # Expect you are now assuming the CloudAdmin role in the prod account
{
    "UserId": "<user ID>",
    "Account": "<prod account ID>",
    "Arn": "arn:aws:sts::<prod account ID>:assumed-role/CloudAdmin/botocore-session-1644219893"
}
$ aws s3 ls                     # You should see your Terraform state bucket listed in the output. Example below:
<YYYY-MM-DD HH:MM:SS> <unique bucket prefix>-prod-us-west-2-terraform-state
```

# Adding a New Environment

Follow these steps in order to add a new environment:

1. Define a new block under `environments:` in `common_vars.yaml`
1. Copy the folder under `live` associated with one of your environments and paste as a new folder with a unique name. In this example, you could make a copy of `dev` and rename it to `staging`
1. Create the new account

    ```bash
    $ cd live/root
    $ terragrunt run-all plan   # Expect creation of a new AWS account and an update to the root account's CloudAdmin IAM role
    $ terragrunt run-all apply
1. Repeat the steps specified in [Create IAM Roles in Child Accounts ](#create-iam-roles-in-child-accounts) for the new account
1. Done!
