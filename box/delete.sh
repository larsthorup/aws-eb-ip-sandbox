if [ -z "$AWS_VPC_NAME" ]; then { echo "Error: run . script/configure"; exit 1; } fi

AWS_VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --output text \
  --query 'Vpcs[0].VpcId' \
)

echo Detaching and deleting internet gateway for $AWS_VPC_ID
AWS_VPC_INTERNET_GATEWAY_ID=$(aws ec2 describe-internet-gateways \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --output text \
  --query 'InternetGateways[0].InternetGatewayId' \
)
aws ec2 detach-internet-gateway \
  --internet-gateway-id $AWS_VPC_INTERNET_GATEWAY_ID \
  --vpc-id $AWS_VPC_ID
aws ec2 delete-internet-gateway \
  --internet-gateway-id $AWS_VPC_INTERNET_GATEWAY_ID


echo Deleting subnets for $AWS_VPC_ID

AWS_SUBNET_ID0=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$AWS_VPC_ID \
  --output text \
  --query 'Subnets[0].SubnetId' \
)
aws ec2 delete-subnet \
  --subnet-id $AWS_SUBNET_ID0

echo Deleting $AWS_VPC_ID

aws ec2 delete-vpc \
  --vpc-id $AWS_VPC_ID
