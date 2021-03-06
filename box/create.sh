DIR="${BASH_SOURCE%/*}"
. $DIR/../configure.sh

echo -----------------

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

echo -----------------

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

echo -----------------

echo Creating "nat" subnet in $AWS_VPC_ID

AWS_SUBNET_ID_NAT=$(aws ec2 create-subnet \
  --vpc-id $AWS_VPC_ID \
  --cidr-block $AWS_NAT_CIDR_BLOCK \
  --output text \
  --query 'Subnet.SubnetId' \
)
aws ec2 modify-subnet-attribute \
  --subnet-id $AWS_SUBNET_ID_NAT \
  --map-public-ip-on-launch
aws ec2 create-tags \
  --resources $AWS_SUBNET_ID_NAT \
  --tags Key=Name,Value=nat
echo $AWS_SUBNET_ID_NAT created

echo -----------------

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

echo -----------------

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

echo -----------------

echo Creating NAT gateway in "nat" subnet of $AWS_VPC_ID and associate static IP

AWS_NAT_GATEWAY_ID=$(aws ec2 create-nat-gateway \
  --subnet-id $AWS_SUBNET_ID_NAT \
  --allocation-id $AWS_VPC_ADDRESS_ALLOCATION_ID \
  --output text \
  --query 'NatGateway.NatGatewayId' \
)
sleep 2
while [ "$(aws ec2 describe-nat-gateways \
  --filter Name=vpc-id,Values=$AWS_VPC_ID \
  --output text \
  --query 'NatGateways[0].State')" != "available" ]
do
  echo -n .
  sleep 2
done
echo

echo $AWS_NAT_GATEWAY_ID created

echo -----------------

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

echo -----------------

echo Adding route for 0.0.0.0/0 through $AWS_NAT_GATEWAY_ID in new "eb" route table

AWS_EB_ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $AWS_VPC_ID \
  --output text \
  --query 'RouteTable.RouteTableId' \
)
aws ec2 create-tags \
  --resources $AWS_EB_ROUTE_TABLE_ID \
  --tags Key=Name,Value=eb

aws ec2 create-route \
  --route-table-id $AWS_EB_ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $AWS_NAT_GATEWAY_ID

aws ec2 associate-route-table \
  --route-table-id $AWS_EB_ROUTE_TABLE_ID \
  --subnet-id $AWS_SUBNET_ID_EB

echo Route for external IP through NAT gateway added to $AWS_EB_ROUTE_TABLE_ID

echo -----------------

