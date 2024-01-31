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

aws cloudfront create-origin-access-control \
    --origin-access-control-config Name=s3OAC,Description=sts3OAC,SigningProtocol=sigv4,SigningBehavior=no-override,OriginAccessControlOriginType=s3

aws cloudfront create-distribution \
    --origin-domain-name $s3bucketname.s3.amazonaws.com \
    --default-root-object index.html \