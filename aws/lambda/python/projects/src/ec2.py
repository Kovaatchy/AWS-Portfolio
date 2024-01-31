import boto3

import sys


ec2 = boto3.resource('ec2',region_name='us-east-1')
     
client = boto3.client('ec2',region_name='us-east-1')

class myEC2:
    ec2 = boto3.resource('ec2',region_name='us-east-1')
     
    client = boto3.client('ec2',region_name='us-east-1')
    def __init__(self):
        pass
    def instance(self,ami,keyType,subnet,keyname,sg):
        instance = ec2.create_instances(
            ImageId=ami,
            InstanceType=keyType,
            MaxCount=1,
            MinCount=1,
            KeyName=keyname,
            NetworkInterfaces=[
                {
                    'AssociatePublicIpAddress': True,
                    'DeleteOnTermination': True,
                    'DeviceIndex': 0,
                    'Groups': [
                        sg
                    ],
                    'SubnetId': subnet,
                    

                }
            ]
            
        )
        return instance
