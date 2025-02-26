#!/bin/bash
OUTPUT=attachment.txt
RECIPIENT=cplus.shen@gmail.com

PATH=$HOME/venv/bin:$PATH
AGENT_HOME=/home/cplus/cp-agent

echo -e "$(date)" | tee $OUTPUT
echo -e "\nUS 10 Year Bond Yield Rate" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python $AGENT_HOME/bond/us-10-bond-yield.py | tee -a $OUTPUT

echo -e "\nUSD to NTD Exchange Rate" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python $AGENT_HOME/currency/usd_to_ntd_exchange.py | tee -a $OUTPUT

echo -e "\nTW Stock" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python $AGENT_HOME/stock/taiwan_stock_price.py | tee -a $OUTPUT

# Send report
python $AGENT_HOME/sendmail-ses.py -f $OUTPUT -m $RECIPIENT

# clean up
# rm -f $OUTPUT
