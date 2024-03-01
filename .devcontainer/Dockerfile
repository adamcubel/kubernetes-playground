FROM registry1.dso.mil/ironbank/hashicorp/terraform:1.7.3

# Install the AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && mkdir -p /tmp/awscli \
    && unzip /tmp/awscliv2.zip -d /tmp/awscli \
    && /tmp/awscli/aws/install \
    && rm -f /tmp/awscliv2.zip \
    && rm -rf /tmp/awscli
