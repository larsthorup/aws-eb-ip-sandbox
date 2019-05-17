DIR="${BASH_SOURCE%/*}"
. $DIR/../configure.sh

aws ec2 describe-vpcs \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --query 'Vpcs[*]'

AWS_VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --output text \
  --query 'Vpcs[0].VpcId' \
)

aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$AWS_VPC_ID \
  --query 'Subnets[*]'

aws ec2 describe-internet-gateways \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --query 'InternetGateways[*]'

aws ec2 describe-addresses \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --query 'Addresses[*]'

aws ec2 describe-nat-gateways \
  --filter Name=vpc-id,Values=$AWS_VPC_ID \
  --query 'NatGateways[*]'

aws elasticbeanstalk describe-environments \
  --application-name $AWS_EB_APP_NAME \
  --environment-names $AWS_EB_ENVIRONMENT_NAME \
  --query 'Environments[*]'

AWS_EB_ENVIRONMENT_ID=$(aws elasticbeanstalk describe-environments \
  --application-name $AWS_EB_APP_NAME \
  --environment-names $AWS_EB_ENVIRONMENT_NAME \
  --output text \
  --query 'Environments[0].EnvironmentId' \
)

if [ "$AWS_EB_ENVIRONMENT_ID" == "None" ]; then
  echo No environment
else

  aws elasticbeanstalk describe-environment-resources \
    --environment-name $AWS_EB_ENVIRONMENT_NAME

  aws ec2 describe-instances \
    --filters Name=vpc-id,Values=$AWS_VPC_ID \
    --query 'Reservations[*]'

  AWS_ELB_NAME=$(aws elasticbeanstalk describe-environment-resources \
    --environment-name $AWS_EB_ENVIRONMENT_NAME \
    --output text \
    --query 'EnvironmentResources.LoadBalancers[0].Name' \
  )

  aws elb describe-load-balancers \
    --load-balancer-name $AWS_ELB_NAME \
    --query 'LoadBalancerDescriptions[*]'

fi
