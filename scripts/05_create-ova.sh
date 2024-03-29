# WARNING THIS IS MOSTLY A MANUAL PROCESS
# PLEASE VISIT FOR INSTRUCTIONS ON EXPORTING YOUR VM:
#  IF RUNNING AMAZON LINUX, DO THIS FIRST. THE VAR NAME MIGHT BE GRUB_ENABLE_BLSCFG OR SOMETHING.
#  I WAS TOO TIRED TO REMEMBER
#  - https://repost.aws/knowledge-center/ami-resolve-import-export-blsc-error
#  - https://docs.aws.amazon.com/vm-import/latest/userguide/vmexport.html
# TODO: Take inputs for bucket name and cloud so that 
#   the bucket can be created if need be
#   the bucket access policy can be applied

s3_bucket=${s3_bucket:-"nifi-demo-sisyphus"} # This is set within the Dockerfile
environment=${environment:-"low"}

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
done

# TODO: THIS NEEDS TLC. WORK IN PROGRESS
# 
# if aws s3api head-bucket --bucket "$s3_bucket" 2>/dev/null; then
#     echo "bucket already exists"
# else
#     echo "aws s3api create-bucket --bucket $s3_bucket"
#     aws s3api create-bucket --bucket "$s3_bucket" --acl private
# fi

# EXPORT_WRITER_ID=""
# if [[ "$environment" == "low" ]]; then
#     EXPORT_WRITER_ID="c4d8eabf8db69dbe46bfe0e517100c554f01200b104d59cd408e777ba442a322"
# else
#     EXPORT_WRITER_ID="af913ca13efe7a94b88392711f6cfc8aa07c9d1454d4f190a624b126733a5602"
# fi

# aws s3api put-bucket-acl --bucket "$s3_bucket" --grant-read-acp id=$EXPORT_WRITER_ID
# aws s3api put-bucket-acl --bucket "$s3_bucket" --grant-write id=$EXPORT_WRITER_ID

cat > ./file.json << EOF
{
    "ContainerFormat": "ova",
    "DiskImageFormat": "VMDK",
    "S3Bucket": "$s3_bucket",
    "S3Prefix": "vms/"
}
EOF

# TODO: Manually edit grub change to automated process
# https://repost.aws/knowledge-center/ami-resolve-import-export-blsc-error

INSTANCE_ID=$(cat /var/lib/cloud/data/instance-id)
echo "aws ec2 create-instance-export-task --instance-id $INSTANCE_ID --target-environment vmware --export-to-s3-task file://\"file.json\""
aws ec2 create-instance-export-task --instance-id $INSTANCE_ID --target-environment vmware --export-to-s3-task file://"file.json" >/dev/null

# Import Steps
# https://docs.aws.amazon.com/vm-import/latest/userguide/prerequisites.html
# https://docs.aws.amazon.com/imagebuilder/latest/userguide/vm-import-export.html
# https://docs.aws.amazon.com/vm-import/latest/userguide/required-permissions.html#vmimport-role
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/ShareObjectPreSignedURL.html