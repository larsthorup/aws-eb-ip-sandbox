if [ -z "$AWS_VPC_NAME" ]; then { echo "Error: run . script/configure"; exit 1; } fi

aws ec2 describe-vpcs --filters Name=tag:Name,Values=$AWS_VPC_NAME --query 'Vpcs[*]'
AWS_VPC_ID=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=$AWS_VPC_NAME --output text --query 'Vpcs[0].VpcId')
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$AWS_VPC_ID"
