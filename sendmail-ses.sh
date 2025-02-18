#!/bin/bash -x

aws ses send-email \
    --from "cplus.shen@gmail.com" \
    --destination "ToAddresses=cplus.shen@gmail.com" \
    --message "Subject={Data=Amazon SES Test Email 2025-1218 11:01},\
    Body={Text={Data=This email was sent with Amazon SES using the AWS CLI.}}"
