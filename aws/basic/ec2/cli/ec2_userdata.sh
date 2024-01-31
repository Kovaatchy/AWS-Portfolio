#!/bin/bash
export sg="ec2-sg-test"
export vpc=$(aws ec2 describe-vpcs | jq -r '.Vpcs[0].VpcId')
export cidr="0.0.0.0/0"
export ssh_port=22
export http_port=80
export key_name="ec2-test"
export subnet=$(aws ec2 describe-subnets --filter "Name=vpc-id,Values=$vpc" | jq -r '.Subnets[0].SubnetId')

###################

aws ec2 create-key-pair --key-name $key_name --query 'KeyMaterial' --output text > ec2-test.pem
#aws ec2 describe-key-pairs --key-name ec2-test

# To retrieve the KeyPair use following commands: 
# aws ec2 describe-key-pairs --filters Name=key-name,Values=new-key-pair --query KeyPairs[*].KeyPairId --output text 
# aws ssm get-parameter --name /ec2/keypair/"result of describe-key-pairs command" --with-decryption --query Parameter.Value --output text > new-key-pair.pem

###################

aws ec2 create-security-group --group-name $sg --description "My security group" --vpc-id $vpc

export sgid=$(aws ec2 describe-security-groups --group-name $sg | jq -r '.SecurityGroups.GroupId')

aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port $ssh_port --cidr $cidr
aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port $http_port --cidr $cidr
#aws ec2 describe-security-groups --group-id $sgid

###################

aws ec2 run-instances --image-id ami-079db87dc4c10ac91 --count 1 --instance-type t2.micro --key-name $key_name --security-group-ids $sgid --subnet-id $subnet --user-data file://userdata.txt
