DIR="${BASH_SOURCE%/*}"
. $DIR/../configure.sh

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

echo $AWS_VPC_ID created

echo Creating "eb" subnet in $AWS_VPC_ID

AWS_SUBNET_ID_EB=$(aws ec2 create-subnet \
  --vpc-id $AWS_VPC_ID \
  --cidr-block $AWS_EB_CIDR_BLOCK \
  --output text \
  --query 'Subnet.SubnetId' \
)
aws ec2 modify-subnet-attribute \
  --subnet-id $AWS_SUBNET_ID_EB \
  --map-public-ip-on-launch
aws ec2 create-tags \
  --resources $AWS_SUBNET_ID_EB \
  --tags Key=Name,Value=eb
echo $AWS_SUBNET_ID_EB created

echo Creating and attaching internet gateway in $AWS_VPC_ID

AWS_VPC_INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway \
  --output text \
  --query 'InternetGateway.InternetGatewayId' \
)
aws ec2 create-tags \
  --resources $AWS_VPC_INTERNET_GATEWAY_ID \
  --tags Key=Name,Value=$AWS_VPC_NAME

aws ec2 attach-internet-gateway \
  --internet-gateway-id $AWS_VPC_INTERNET_GATEWAY_ID \
  --vpc-id $AWS_VPC_ID

echo $AWS_VPC_INTERNET_GATEWAY_ID created and attached to $AWS_VPC_ID

echo Adding route for 0.0.0.0/0 through $AWS_VPC_INTERNET_GATEWAY_ID in main route table of $AWS_VPC_ID

AWS_VPC_MAIN_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables \
  --filters Name=vpc-id,Values=$AWS_VPC_ID Name=association.main,Values=true \
  --output text \
  --query 'RouteTables[0].RouteTableId' \
)
aws ec2 create-route \
  --route-table-id $AWS_VPC_MAIN_ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $AWS_VPC_INTERNET_GATEWAY_ID

echo Route for 0.0.0.0/0 through internet gateway added to $AWS_VPC_MAIN_ROUTE_TABLE_ID

echo Allocating static IP address to $AWS_VPC_ID

AWS_VPC_ADDRESS_ALLOCATION_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --output text \
  --query 'AllocationId' \
)
aws ec2 create-tags \
  --resources $AWS_VPC_ADDRESS_ALLOCATION_ID \
  --tags Key=Name,Value=$AWS_VPC_NAME

echo Allocation $AWS_VPC_ADDRESS_ALLOCATION_ID created
