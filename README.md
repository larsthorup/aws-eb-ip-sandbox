# aws-eb-ip-sandbox

Create AWS Elastic Beanstalk environment with fixed ip outbound requests for white list protecting external services

## Prerequisites

* Bash
* AWS account
* https://console.aws.amazon.com/iam/home/
  * Users | user | Security Credentials | Create access key
* https://aws.amazon.com/cli/
* `aws configure`
* https://github.com/aws/aws-elastic-beanstalk-cli-setup
* `eb init`
  * select region: eu-central-1
  * create application: aws-eb-ip-sandbox
  * create SSH key pair: aws-eb-ip-sandbox

## Box creation

    . configure
    box/create
    box/list
    box/delete
