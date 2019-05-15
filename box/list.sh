if [ -z "$AWS_VPC_NAME" ]; then { echo "Error: run . script/configure"; exit 1; } fi

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

aws elasticbeanstalk describe-environments \
  --application-name $AWS_EB_APP_NAME \
  --environment-names $AWS_EB_ENVIRONMENT_NAME

aws elasticbeanstalk describe-environment-resources \
  --environment-name $AWS_EB_ENVIRONMENT_NAME

aws ec2 describe-instances \
  --filters Name=vpc-id,Values=$AWS_VPC_ID

AWS_ELB_NAME=$(aws elasticbeanstalk describe-environment-resources \
  --environment-name $AWS_EB_ENVIRONMENT_NAME \
  --output text \
  --query 'EnvironmentResources.LoadBalancers[0].Name' \
)

aws elb describe-load-balancers \
  --load-balancer-name $AWS_ELB_NAME
