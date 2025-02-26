#!/bin/bash -x
OUTPUT=attachment.md
RECIPIENT=cplus.shen@gmail.com

echo -e "= Daily Report $(date)\n" | tee $OUTPUT
echo -e "== US 10 Year Bond Yield Rate" | tee -a $OUTPUT
python bond/us-10-bond-yield.py | tee -a $OUTPUT

echo -e "\n== USD to NTD Exchange Rate" | tee -a $OUTPUT
python currency/usd_to_ntd_exchange.py | tee -a $OUTPUT

echo -e "\n== TW Stock" | tee -a $OUTPUT
python stock/taiwan_stock_price.py | tee -a $OUTPUT

# Send report
python sendmail-ses.py -f $OUTPUT -m $RECIPIENT
