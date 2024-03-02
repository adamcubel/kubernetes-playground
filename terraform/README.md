To deploy the terraform within this directory, you will need to first have Terraform installed. To do so, the easiest way is to use the HomeBrew package repository to install the tool. To install the HomeBrew package manager, issue the following commands on the EC2 VM:

```
CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/ec2-user/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

After you've installed HomeBrew, install Terraform using the following command:

```
brew install terraform
```

From here, you can make sure that the AWS CLI is installed and that an EC2 role has been assigned to your VM such that it has permissions to create and manage AWS infrastructure within your account. If you need assistance creating the necessary permissions to create the resources defined within the Terraform Infrastructure as Code, you will need to consult with your Identity and Access Management (IAM) resources to get access to the permissions you need added to the role.

In ACloudGuru, you need the following permissions:
- allow_all
- Playground_AWS_Sandbox

Ensure that the Role has the following Trust Policy:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com",
                "AWS": "arn:aws:sts::AWS-account-ID:assumed-role/role-name/role-session-name"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

For more information on configuring the AWS CLI, please see the [README](../scripts/README.md) in the scripts directory, and the [add-aws-config-to-vm.sh](../scripts/add-aws-config-to-vm.sh) script to aid in setting up the AWS CLI for your environment in preparation for deploying Terraform.

At this point, you will need to configure parameters for deployment. An example exists in [cloudguru.tfvars](env/low/cloudguru.tfvars). You will need to replace many of the values in this example deployment to match the identities of existing resources in your environment.

```
terraform init
```

```
mkdir -p ~/terraform_providers
terraform providers mirror ~/terraform_providers
```


```
terraform plan -var-file="./env/low/cloudguru.tfvars"
```
