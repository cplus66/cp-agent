#!/bin/bash
OUTPUT=attachment.txt
RECIPIENT=cplus.shen@gmail.com

PATH=$HOME/venv/bin:$PATH
AGENT_HOME=$HOME/cp-agent

echo -e "$(date)" | tee $OUTPUT
echo -e "\nUS 10 Year Bond Yield Rate" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python3 $AGENT_HOME/bond/us-10-bond-yield.py | tee -a $OUTPUT

echo -e "\nUSD to NTD Exchange Rate" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python3 $AGENT_HOME/currency/usd_to_ntd_exchange.py | tee -a $OUTPUT

echo -e "\nTW Stock(ALL)" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python3 $AGENT_HOME/stock/taiwan_stock_price.py | tee -a $OUTPUT

echo -e "\nTW Stock Only" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-stock.txt | tee -a $OUTPUT

echo -e "\nTW Stock (Bond EFT)" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-bond.txt | tee -a $OUTPUT

echo -e "\nTW Stock (2345)" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-2345.txt | tee -a $OUTPUT

echo -e "\nTW Stock (5770)" | tee -a $OUTPUT
echo -e "==========================" | tee -a $OUTPUT
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-5770.txt | tee -a $OUTPUT

# Send report
python3 $AGENT_HOME/sendmail-ses.py -f $OUTPUT -m $RECIPIENT

# clean up
# rm -f $OUTPUT
