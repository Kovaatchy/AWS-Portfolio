#!/bin/bash
export vpc=$(aws ec2 describe-vpcs | jq -r '.Vpcs[0].VpcId') # get the default vpc
export subnetA=$(aws ec2 describe-subnets --filter "Name=vpc-id,Values=$vpc" | jq -r '.Subnets[0].SubnetId')
export subnetB=$(aws ec2 describe-subnets --filter "Name=vpc-id,Values=$vpc" | jq -r '.Subnets[1].SubnetId')
export subnetC=$(aws ec2 describe-subnets --filter "Name=vpc-id,Values=$vpc" | jq -r '.Subnets[3].SubnetId')
export sg="ec2-sg-test"
export cidr="0.0.0.0/0"
export ssh_port=22
export http_port=80
export lbTargetGroupName="asg-lbGroup"
export launchTemplateName="my_lc"
export amiId="ami-079db87dc4c10ac91"
export instanceType="t2.micro"
export keypairName="ec2_asg_kp"
export userdataFile=file://userdata.txt

################################################################################################

aws ec2 create-key-pair --key-name $keypairName --query 'KeyMaterial' --output text > ec2_asg_kp.pem

# To retrieve the KeyPair use following commands: 
# aws ec2 describe-key-pairs --filters Name=key-name,Values=new-key-pair --query KeyPairs[*].KeyPairId --output text 
# aws ssm get-parameter --name /ec2/keypair/"result of describe-key-pairs command" --with-decryption --query Parameter.Value --output text > new-key-pair.pem

################################################################################################

aws ec2 create-security-group --group-name $sg --description "My security group" --vpc-id $vpc

export sgid=$(aws ec2 describe-security-groups --group-name $sg | jq -r '.SecurityGroups[].GroupId')

aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port $ssh_port --cidr $cidr
aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port $http_port --cidr $cidr

################################################################################################

aws elbv2 create-load-balancer \
    --name my-load-balancer \
    --subnets $subnetA $subnetB $subnetC \
    --security-groups $sgid

export LoadBalancerArn=$(aws elbv2 describe-load-balancers --name my-load-balancer | jq -r '.LoadBalancers[].LoadBalancerArn')

aws elbv2 create-target-group --name $lbTargetGroupName --protocol HTTP --port 80 \
    --vpc-id $vpc --ip-address-type ipv4

export targetGroupArn=$(aws elbv2 describe-target-groups --name $lbTargetGroupName | jq -r '.TargetGroups[].TargetGroupArn')

aws elbv2 create-listener --load-balancer-arn $LoadBalancerArn \
    --protocol HTTP --port 80  \
    --default-actions Type=forward,TargetGroupArn=$targetGroupArn

################################################################################################

aws autoscaling create-launch-configuration \
    --launch-configuration-name $launchTemplateName \
    --image-id $amiId \
    --instance-type $instanceType \
    --security-groups $sgid \
    --key-name $keypairName \
    --user-data $userdataFile \
    --instance-monitoring Enabled=true

################################################################################################

aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name my-asg \
    --launch-configuration-name $launchTemplateName  \
    --target-group-arns $targetGroupArn \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --desired-capacity 2 \
    --min-size 1 \
    --max-size 3 \
    --vpc-zone-identifier "$subnetA,$subnetB,$subnetC"


