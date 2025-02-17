import boto3

def list_buckets():
    """List all S3 buckets"""
    s3_client = boto3.client('s3')
    response = s3_client.list_buckets()
    print('Existing buckets:')
    for bucket in response['Buckets']:
        print(f'  {bucket["Name"]}')

if __name__ == '__main__':
    list_buckets()
