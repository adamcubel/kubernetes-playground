# TODO: Take inputs for bucket name and cloud so that 
#   the bucket can be created if need be
#   the bucket access policy can be applied

s3_bucket=${s3_bucket:-"nifi-demo-$RANDOM"} # This is set within the Dockerfile
environment=${environment:-"default"}
instance_id=${instance_id:-"$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)"}

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi
  shift
  
done


if aws s3api head-bucket --bucket "$s3_bucket" 2>/dev/null; then
    echo "bucket already exists"
else
    echo "aws s3api create-bucket --bucket $s3_bucket"
    aws s3api create-bucket --bucket "$s3_bucket"
fi

EXPORT_WRITER_ID=""
if [[ "$environment" == "default" ]]; then
    EXPORT_WRITER_ID="c4d8eabf8db69dbe46bfe0e517100c554f01200b104d59cd408e777ba442a322"
else
    EXPORT_WRITER_ID="af913ca13efe7a94b88392711f6cfc8aa07c9d1454d4f190a624b126733a5602"
fi


aws s3api put-bucket-acl --bucket "$s3_bucket" --grant-read id=$EXPORT_WRITER_ID

aws s3api put-bucket-acl --bucket "$s3_bucket" --grant-write id=$EXPORT_WRITER_ID

cat > ./file.json << EOF
{
    "ContainerFormat": "ova",
    "DiskImageFormat": "VMDK",
    "S3Bucket": "$s3_bucket",
    "S3Prefix": "vms/"
}
EOF

set -x
aws ec2 create-instance-export-task --instance-id $instance_id --target-environment vmware --export-to-s3-task file://"file.json"
set +x