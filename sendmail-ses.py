import boto3
from botocore.exceptions import ClientError
import os
import mimetypes
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import argparse

def send_email(sender, recipient, subject, body_text, body_html, attachment_path):
    # AWS SES client
    ses_client = boto3.client('ses')

    # Create a multipart/mixed parent container
    msg = MIMEMultipart('mixed')
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = recipient

    # Create a multipart/alternative child container
    msg_body = MIMEMultipart('alternative')

    # Encode the text and HTML content
    textpart = MIMEText(body_text, 'plain')
    htmlpart = MIMEText(body_html, 'html')

    # Attach parts into message container.
    msg_body.attach(textpart)
    msg_body.attach(htmlpart)

    # Define the attachment part and encode it using MIMEApplication
    if attachment_path:
        with open(attachment_path, 'rb') as attachment:
            att = MIMEApplication(attachment.read())
            att.add_header('Content-Disposition', 'attachment', filename=os.path.basename(attachment_path))
            msg.attach(att)

    # Attach the multipart/alternative child container to the multipart/mixed parent container
    msg.attach(msg_body)

    try:
        # Provide the contents of the email
        response = ses_client.send_raw_email(
            Source=sender,
            Destinations=[recipient],
            RawMessage={
                'Data': msg.as_string(),
            }
        )
    except ClientError as e:
        print(f"Error: {e.response['Error']['Message']}")
    else:
        print(f"Email sent! Message ID: {response['MessageId']}")

def get_attachment_content(attachment_path):
    if attachment_path:
        with open(attachment_path, 'r') as attachment:
            return attachment.read()
    return ""

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Send an email with an attachment using AWS SES.')
    parser.add_argument('-f', '--file', required=True, help='The file path of the attachment.')
    parser.add_argument('-m', '--mail', required=True, help='The email address of the sender and recipient.')

    args = parser.parse_args()

    SENDER = args.mail
    RECIPIENT = args.mail
    SUBJECT = "[cp-agent] daily report"

    attachment_content = get_attachment_content(args.file)
    BODY_TEXT = f"FIRE Daily Report,\r\n{attachment_content}"
    BODY_HTML = """<html>
    <head></head>
    <body>
      <h1>FIRE Daily Report</h1>
      <pre>{0}</pre>
    </body>
    </html>""".format(attachment_content.replace('\n', '<br>'))
    ATTACHMENT_PATH = args.file

    send_email(SENDER, RECIPIENT, SUBJECT, BODY_TEXT, BODY_HTML, ATTACHMENT_PATH)
