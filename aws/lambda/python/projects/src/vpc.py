import boto3

ec2 = boto3.resource('ec2',region_name='us-east-1')

client = boto3.client('ec2',region_name='us-east-1')

class myVPC:
     
     
     ec2 = boto3.resource('ec2',region_name='us-east-1')
     
     client = boto3.client('ec2',region_name='us-east-1')
     
     def __init__(self):
          pass
     def vpc(self,cidrblock):
          vpc = ec2.create_vpc(
               CidrBlock=cidrblock
          )
          return vpc
     def route_table(self,vpcid):
          route = ec2.create_route_table(
               VpcId = vpcid
          )
          return route
     def subnet(self, i, vpcid):
          subnet = ec2.create_subnet(
               CidrBlock=i,
               VpcId = vpcid
          )
          return subnet
     def rtAssociatesub(self,subnet, route_table):
          response = client.associate_route_table(
               RouteTableId=route_table,
               SubnetId=subnet
          )
          return response
     
     def internetGateway(self):
          internet_gateway = ec2.create_internet_gateway()
          return internet_gateway
     
     def attachIg(self,ig, vpcid):
          response = client.attach_internet_gateway(
               InternetGatewayId=ig,
               VpcId=vpcid,
          )
          # print(response)
          
     def rtRouteIg(self, ig, rt):
          response = client.create_route(
               DestinationCidrBlock="0.0.0.0/0",
               GatewayId=ig,
               RouteTableId=rt
          )
          return response

     def create_subnet(self,subnetsA, subnetsB, vpcid,rt):
          subnetsA = subnetsA
          subnetsB = subnetsB
          subnetidA = []
          subnetidB = []
          p = myVPC()
          for i in subnetsA:
               subnets = p.subnet(i, vpcid)
               rtAssoc = p.rtAssociatesub(subnets.id, rt)
               subnetidA.append(subnets.id)
               print(i)
               print(vpcid)
               print(rt)
          for i in subnetsB:
               subnets = p.subnet(i, vpcid)
               subnetidB.append(subnets.id)
          return subnetidA,subnetidB
      

