DIR="${BASH_SOURCE%/*}"
. $DIR/../configure.sh

AWS_VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --output text \
  --query 'Vpcs[0].VpcId' \
)

echo Deleting NAT Gateway for $AWS_VPC_ID

AWS_NAT_GATEWAY_ID=$(aws ec2 describe-nat-gateways \
  --filter Name=vpc-id,Values=$AWS_VPC_ID \
  --output text \
  --query 'NatGateways[0].NatGatewayId' \
)
aws ec2 delete-nat-gateway \
  --nat-gateway-id $AWS_NAT_GATEWAY_ID

sleep 2
while [ "$(aws ec2 describe-nat-gateways \
  --filter Name=vpc-id,Values=$AWS_VPC_ID \
  --output text \
  --query 'NatGateways[0].State')" == "deleting" ]
do
  aws ec2 describe-nat-gateways \
    --filter Name=vpc-id,Values=$AWS_VPC_ID \
    --output text \
    --query 'NatGateways[0].State'
  sleep 2
done

echo Releasing static IP address for $AWS_VPC_ID

AWS_VPC_ADDRESS_ALLOCATION_ID=$(aws ec2 describe-addresses \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --output text \
  --query 'Addresses[0].AllocationId' \
)
aws ec2 release-address \
  --allocation-id $AWS_VPC_ADDRESS_ALLOCATION_ID

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
sleep 10 # Note: wait for subnets to no longer be dependencies of the VPC

echo Deleting $AWS_VPC_ID

aws ec2 delete-vpc \
  --vpc-id $AWS_VPC_ID
