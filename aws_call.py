import os
import boto3
from botocore.exceptions import ClientError
import json


def get_secret(secret_name):

    region_name = "us-west-2"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    secret = get_secret_value_response['SecretString']

    #Convert to json format to retrieve the key value
    secret=json.loads(secret)
   
    #print(secret)
    for key,value in secret.items():
        os.environ[key]=value
    return value
