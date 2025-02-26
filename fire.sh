#!/bin/bash -x
OUTPUT=attachment.txt
RECIPIENT=cplus.shen@gmail.com

echo -e "Daily Report - $(date)" | tee $OUTPUT
echo -e "\nUS 10 Year Bond Yield Rate" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python bond/us-10-bond-yield.py | tee -a $OUTPUT

echo -e "\nUSD to NTD Exchange Rate" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python currency/usd_to_ntd_exchange.py | tee -a $OUTPUT

echo -e "\nTW Stock" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python stock/taiwan_stock_price.py | tee -a $OUTPUT

# Send report
python sendmail-ses.py -f $OUTPUT -m $RECIPIENT

# clean up
# rm -f $OUTPUT
