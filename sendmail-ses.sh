#!/bin/bash -x

aws ses send-email \
    --from "cplus.shen@gmail.com" \
    --destination "ToAddresses=cplus.shen@advantech.com.tw" \
    --message "Subject={Data=Amazon SES Test Email},\
    Body={Text={Data=This email was sent with Amazon SES using the AWS CLI.}}"
