if [ -z "$VPC_NAME" ]; then { echo "Error: run . script/configure"; exit 1; } fi

VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$VPC_NAME --output text --query 'Vpcs[0].VpcId')
aws ec2 delete-vpc --vpc-id $VPC_ID
