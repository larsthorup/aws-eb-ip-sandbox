if [ -z "$VPC_NAME" ]; then { echo "Error: run . script/configure"; exit 1; } fi

VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR_BLOCK --output text --query 'Vpc.VpcId')
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME
