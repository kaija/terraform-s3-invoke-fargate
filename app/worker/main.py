import os
import boto3
import time

print("container starting...")
bucket = os.environ['AWS_BUCKET']
obj = os.environ['AWS_OBJECT']
s3 = boto3.resource('s3')
print("bucket: " + bucket + " object: " + obj)
obj = s3.Object(bucket, obj)
body = obj.get()['Body'].read()
print (body)
time.sleep(60)
print("container ended...")
