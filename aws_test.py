import boto3
import os

# session = boto3.Session(
#     aws_access_key_id=os.environ['AWS_ACCESS_KEY'],
#     aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'],
# )
#
# s3 = session.resource('s3')

id = os.environ['AWS_ACCESS_KEY']
secret = os.environ['AWS_SECRET_ACCESS_KEY']

print(id, secret)
s3 = boto3.resource('s3',
		 aws_access_key_id=os.environ['AWS_ACCESS_KEY'],
		 aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY'])

bucket='duplicity.gautier.org'

some_binary_data = b'Here we have some data'

more_binary_data = b'Here we have some more data'

object = s3.Object(bucket, 'my/key/including/filename.txt')
object.put(Body=some_binary_data)


# client = boto3.client('s3')
# client.put_object(Body=more_binary_data, Bucket=bucket, Key='my/key/including/anotherfilename.txt')2