import boto3
import os
import sys
import time

sys.path.append('src')

from vpc import myVPC
from KeyPair import myKeyPair
from ec2 import myEC2
from securitygp import mySecurityGroup

ec2 = boto3.resource('ec2',region_name='us-east-1')
client = boto3.client('ec2')

AMI=os.environ['AMI']
INSTANCE_TYPE=os.environ['INSTANCE_TYPE']
KEY_NAME=os.environ['KEY_NAME']


def lambda_handler(event, context):
    cidrblock = "10.0.0.0/16"
    subnetsA = ["10.0.1.0/24","10.0.2.0/24"]
    subnetsB = ["10.0.3.0/24","10.0.4.0/24"]
    v = myVPC()
    newVpc = v.vpc(cidrblock).id
    ig = v.internetGateway().id
    rt = v.route_table(newVpc).id
    igAttach = v.attachIg(ig, newVpc)
    rtRoute = v.rtRouteIg(ig, rt)
    mySubnets = v.create_subnet(subnetsA, subnetsB,newVpc,rt)
    subnetEc2 = mySubnets[0][0]
    print("New vpc created:", newVpc)
    print("New internet gateway: ", ig)
    subnetEc2 = str(subnetEc2)
    print(subnetEc2)

    time.sleep(5)

    s= mySecurityGroup()
    mySG = s.securitygp(newVpc).id
    print(mySG)

    time.sleep(5)

    keyName= KEY_NAME
    keytype='rsa'
    keyformat='pem'
    k= myKeyPair()
    newKeypair = k.KeyPair(keyName,keytype,keyformat)
    print(newKeypair)

    time.sleep(5)

    ami=AMI
    instanceType=INSTANCE_TYPE
    subnet=subnetEc2
    i= myEC2()
   
    newInstance=i.instance(ami,instanceType,subnet,keyName,mySG)