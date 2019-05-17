# aws-eb-ip-sandbox

Create AWS Elastic Beanstalk environment with fixed ip outbound requests for white list protecting external services

## Prerequisites

* Node.js
* Bash (on Windows, consider using Git Bash)
* AWS account
* https://console.aws.amazon.com/iam/home/
  * Users | user | Security Credentials | Create access key
* AWS CLI
  * https://aws.amazon.com/cli/
  * `aws configure`
* AWS EB CLI
  * https://github.com/aws/aws-elastic-beanstalk-cli-setup
* `eb init`
  * select region: eu-central-1
  * create application: aws-eb-ip-sandbox
  * create SSH key pair: aws-eb-ip-sandbox
* Verify service roles created:
  * https://console.aws.amazon.com/iam/home?region=eu-central-1#/roles
  * aws-elasticbeanstalk-ec2-role
  * aws-elasticbeanstalk-service-role 
* Create S3 deploy bundle: aws-eb-ip-sandbox

## Box creation

    box/create.sh
    box/create-environment.sh
    box/list.sh
    box/delete.sh

## Test static IP from box

* http://maroon-aws-eb-ip-sandbox.eu-central-1.elasticbeanstalk.com/https://webhook.site/ba6931bb-8a3a-4ee1-8beb-8cb25c015870
