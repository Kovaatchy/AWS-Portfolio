#!/bin/bash

export s3bucketname="tarava-sysnet-website-test"
export s3bucketregion="us-east-1"

################################################################################################

aws s3api create-bucket --bucket $s3bucketname --region $s3bucketregion

################################################################################################

aws s3api put-public-access-block \
    --bucket $s3bucketname \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

################################################################################################

aws s3 cp ../index.html s3://$s3bucketname/index.html

################################################################################################

aws s3api put-bucket-policy --bucket $s3bucketname --policy file://../s3_permissions.json

################################################################################################

aws s3api put-bucket-website --bucket $s3bucketname --website-configuration file://website.json