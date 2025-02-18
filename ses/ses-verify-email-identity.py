import boto3

# Create SES client
ses = boto3.client('ses')

response = ses.verify_email_identity(
  EmailAddress = 'cplus.shen@gmail.com'
)

print(response)
