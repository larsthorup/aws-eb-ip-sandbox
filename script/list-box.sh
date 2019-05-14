if [ -z "$VPC_NAME" ]; then { echo "Error: run . script/configure"; exit 1; } fi

aws ec2 describe-vpcs --filters Name=tag:Name,Values=$VPC_NAME
