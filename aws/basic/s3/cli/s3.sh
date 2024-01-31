export bucket="taravasysnet-s3test"
export region="us-east-1"
aws s3api create-bucket --bucket $bucket --region $region