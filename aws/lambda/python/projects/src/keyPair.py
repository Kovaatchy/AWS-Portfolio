import boto3

ec2 = boto3.resource('ec2',region_name='us-east-1')
     
client = boto3.client('ec2',region_name='us-east-1')

class myKeyPair:
    ec2 = boto3.resource('ec2',region_name='us-east-1')
     
    client = boto3.client('ec2',region_name='us-east-1')
    def __init__(self):
        pass
    def KeyPair(self,name,keytype,keyformat):
        key_pair = ec2.create_key_pair(
            KeyName=name,
            KeyType=keytype,
            KeyFormat=keyformat
        )
        return key_pair