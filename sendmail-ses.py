import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

# Replace these variables with your information
SENDER = "cplus.shen@gmail.com"
RECIPIENT = "cplus.shen@gmail.com"
SUBJECT = "Amazon SES Test Email (Python, 2025-0218, 11:29)"
BODY_TEXT = ("Amazon SES Test Email\n"
             "This email was sent with Amazon SES using the AWS SDK for Python (Boto3)."
             )
BODY_HTML = """<html>
<head></head>
<body>
  <h1>Amazon SES Test Email</h1>
  <p>This email was sent with
    <a href='https://aws.amazon.com/ses/'>Amazon SES</a> using the
    <a href='https://boto3.amazonaws.com/v1/documentation/api/latest/index.html'>AWS SDK for Python (Boto3)</a>.</p>
</body>
</html>
            """
CHARSET = "UTF-8"

# Create a new SES resource and specify a region.
#client = boto3.client('ses',region_name=AWS_REGION)
client = boto3.client('ses')

# Try to send the email.
try:
    # Provide the contents of the email.
    response = client.send_email(
        Destination={
            'ToAddresses': [
                RECIPIENT,
            ],
        },
        Message={
            'Body': {
                'Html': {
                    'Charset': CHARSET,
                    'Data': BODY_HTML,
                },
                'Text': {
                    'Charset': CHARSET,
                    'Data': BODY_TEXT,
                },
            },
            'Subject': {
                'Charset': CHARSET,
                'Data': SUBJECT,
            },
        },
        Source=SENDER,
#        SourceArn='arn:aws:ses:us-east-1:270180045065:identity/cplus.shen@gmail.com',
    )
# Display an error if something goes wrong.
except (NoCredentialsError, PartialCredentialsError) as e:
    print(f"Error: {e}")
else:
    print("Email sent! Message ID:"),
    print(response['MessageId'])
