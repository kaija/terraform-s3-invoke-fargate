import json
import logging
import os
import time
import uuid
from datetime import datetime
import boto3

REGION = os.environ['REGION']
FARGATE_CLUSTER = os.environ['FARGATE_CLUSTER']
FARGATE_TASK_DEF_NAME = os.environ['FARGATE_TASK_DEF_NAME']


def run_fargate_task(s3bucket, s3object):
    client = boto3.client('ecs', region_name=REGION)
    response = client.run_task(
        cluster=FARGATE_CLUSTER,
        launchType = 'FARGATE',
        taskDefinition=FARGATE_TASK_DEF_NAME,
        count = 1,
        platformVersion='LATEST',
        networkConfiguration={
            'awsvpcConfiguration': {
                'subnets': [
                    'subnet-9b1fd3fe',
                ],
                'assignPublicIp': 'ENABLED'
            }
        },
        overrides={
            'containerOverrides': [
                {
                    'name': 'worker',
                    'environment': [
                        {
                            'name': 'AWS_BUCKET',
                            'value': s3bucket
                        },
                        {
                            'name': 'AWS_OBJECT',
                            'value': s3object
                        }
                    ],
                },
            ],
        },
    )
    return str(response)

def fargate(event, context):

    print(json.dumps(event))

    s3bucket = event['Records'][0]['s3']['bucket']['name']
    s3object = event['Records'][0]['s3']['object']['key']
    response = run_fargate_task(s3bucket, s3object)
    res = json.dumps(response)
    print(res)
    return response
