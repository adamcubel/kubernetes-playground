FROM registry1.dso.mil/ironbank/hashicorp/terraform:1.7.3

USER 0

ARG TERRAFORM_AWS_PROVIDER_VERSION=4.46.0
ARG TERRAFORM_EXTERNAL_PROVIDER_VERSION=2.2.3
ARG TERRAFORM_LOCAL_PROVIDER_VERSION=2.2.3
ARG TERRAFORM_NULL_PROVIDER_VERSION=3.2.1

# Install OS package dependencies
RUN yum install -y wget

RUN wget --quiet https://releases.hashicorp.com/terraform-provider-aws/${TERRAFORM_AWS_PROVIDER_VERSION}/terraform-provider-aws_${TERRAFORM_AWS_PROVIDER_VERSION}_linux_amd64.zip -O terraform_aws_provider.zip \
    && mkdir -p /terraform_providers/registry.terraform.io/hashicorp/aws/${TERRAFORM_AWS_PROVIDER_VERSION}/linux_amd64/ \
    && unzip -q terraform_aws_provider.zip -d /terraform_providers/registry.terraform.io/hashicorp/aws/${TERRAFORM_AWS_PROVIDER_VERSION}/linux_amd64/ \
    && rm terraform_aws_provider.zip

RUN wget --quiet https://releases.hashicorp.com/terraform-provider-external/${TERRAFORM_EXTERNAL_PROVIDER_VERSION}/terraform-provider-external_${TERRAFORM_EXTERNAL_PROVIDER_VERSION}_linux_amd64.zip -O terraform_external_provider.zip \
    && mkdir -p /terraform_providers/registry.terraform.io/hashicorp/external/${TERRAFORM_EXTERNAL_PROVIDER_VERSION}/linux_amd64/ \
    && unzip -q terraform_external_provider.zip -d /terraform_providers/registry.terraform.io/hashicorp/external/${TERRAFORM_EXTERNAL_PROVIDER_VERSION}/linux_amd64/ \
    && rm terraform_external_provider.zip

RUN wget --quiet https://releases.hashicorp.com/terraform-provider-local/${TERRAFORM_LOCAL_PROVIDER_VERSION}/terraform-provider-local_${TERRAFORM_LOCAL_PROVIDER_VERSION}_linux_amd64.zip -O terraform_local_provider.zip \
    && mkdir -p /terraform_providers/registry.terraform.io/hashicorp/local/${TERRAFORM_LOCAL_PROVIDER_VERSION}/linux_amd64/ \
    && unzip -q terraform_local_provider.zip -d /terraform_providers/registry.terraform.io/hashicorp/local/${TERRAFORM_EXTERNAL_PROVIDER_VERSION}/linux_amd64/ \
    && rm terraform_local_provider.zip

RUN wget --quiet https://releases.hashicorp.com/terraform-provider-null/${TERRAFORM_NULL_PROVIDER_VERSION}/terraform-provider-null_${TERRAFORM_NULL_PROVIDER_VERSION}_linux_amd64.zip -O terraform_null_provider.zip \
    && mkdir -p /terraform_providers/registry.terraform.io/hashicorp/null/${TERRAFORM_NULL_PROVIDER_VERSION}/linux_amd64/ \
    && unzip -q terraform_null_provider.zip -d /terraform_providers/registry.terraform.io/hashicorp/null/${TERRAFORM_NULL_PROVIDER_VERSION}/linux_amd64/ \
    && rm terraform_null_provider.zip

# Install the AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && mkdir -p /tmp/awscli \
    && unzip /tmp/awscliv2.zip -d /tmp/awscli \
    && /tmp/awscli/aws/install \
    && rm -f /tmp/awscliv2.zip \
    && rm -rf /tmp/awscli

USER terraform

HEALTHCHECK --interval=30s --timeout=10s \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/bin/terraform"]
