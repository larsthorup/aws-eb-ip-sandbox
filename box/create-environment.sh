echo Creating bundle

mkdir -p output
npm run create-bundle

echo Uploading bundle

AWS_EB_APP_VERSION_LABEL=$(date \
  --utc \
  --iso-8601=second \
)

aws s3 cp \
  --region $AWS_REGION \
  output/bundle.zip \
  s3://$AWS_S3_DEPLOY_BUCKET_NAME/bundle-$AWS_EB_APP_VERSION_LABEL.zip

echo Creating application version "$AWS_EB_APP_VERSION_LABEL"

aws elasticbeanstalk create-application-version \
  --region $AWS_REGION \
  --application-name $AWS_EB_APP_NAME \
  --version-label $AWS_EB_APP_VERSION_LABEL \
  --source-bundle S3Bucket=$AWS_S3_DEPLOY_BUCKET_NAME,S3Key=bundle-$AWS_EB_APP_VERSION_LABEL.zip

echo Creating environment for application $AWS_EB_APP_NAME

export AWS_VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=tag:Name,Values=$AWS_VPC_NAME \
  --output text \
  --query 'Vpcs[0].VpcId' \
)
export AWS_SUBNET_ID_EB=$(aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$AWS_VPC_ID Name=tag:Name,Values=eb \
  --output text \
  --query 'Subnets[0].SubnetId' \
)

cat box/environment-settings.json | envsubst > output/environment-settings.json

aws elasticbeanstalk create-environment \
  --region $AWS_REGION \
  --application-name $AWS_EB_APP_NAME \
  --environment-name $AWS_EB_ENVIRONMENT_NAME \
  --cname-prefix $AWS_EB_ENVIRONMENT_NAME-$AWS_EB_APP_NAME \
  --version-label $AWS_EB_APP_VERSION_LABEL \
  --solution-stack-name "64bit Amazon Linux 2018.03 v4.8.3 running Node.js" \
  --option-settings file://output/environment-settings.json
