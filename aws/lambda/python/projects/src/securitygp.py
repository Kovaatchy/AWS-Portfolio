import boto3

ec2 = boto3.resource('ec2',region_name='us-east-1')
     

class mySecurityGroup:
    ec2 = boto3.resource('ec2',region_name='us-east-1')
     
    def __init__(self):
        pass
    def securitygp(self,vpcid):

        security_group = ec2.create_security_group(
            Description='test',
            GroupName='test',
            VpcId=vpcid
        )
        return security_group
    
    def securitygpIngress(self):
        response = client.authorize_security_group_ingress(
            CidrIp='string',
            FromPort=123,
            GroupId='string',
            GroupName='string',
            IpProtocol='string',
            SourceSecurityGroupName='string',
            SourceSecurityGroupOwnerId='string',
            ToPort=123
        )