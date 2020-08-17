import os
import boto3

bucket = os.environ('AWS_BUCKET')
obj = os.environ('AWS_OBJECT')

s3 = boto3.resource('s3')

obj = s3.Object(bucket, obj)
body = obj.get()['Body'].read()
print (body)