if [ -z "$AWS_VPC_NAME" ]; then { echo "Error: run . script/configure"; exit 1; } fi

echo Creating VPC

AWS_VPC_ID=$(aws ec2 create-vpc \
  --region $AWS_REGION \
  --cidr-block $AWS_VPC_CIDR_BLOCK \
  --output text \
  --query 'Vpc.VpcId' \
)
aws ec2 create-tags \
  --resources $AWS_VPC_ID \
  --tags Key=Name,Value=$AWS_VPC_NAME

echo Creating "eb" subnet in $AWS_VPC_ID

AWS_SUBNET_ID_EB=$(aws ec2 create-subnet \
  --vpc-id $AWS_VPC_ID \
  --cidr-block $AWS_EB_CIDR_BLOCK \
  --output text \
  --query 'Subnet.SubnetId' \
)
aws ec2 create-tags \
  --resources $AWS_SUBNET_ID_EB \
  --tags Key=Name,Value=eb
