#!/bin/bash
OUTPUT=attachment.txt
RECIPIENT=cplus.shen@gmail.com

PATH=$HOME/venv/bin:$PATH
AGENT_HOME=$HOME/cp-agent

usage()
{
  echo "./fire.sh [-m]"
}

rm -f $OUTPUT

exec &> >(tee -a "$OUTPUT")

echo -e "$(date)" 
echo -e "\nUS 10 Year Bond Yield Rate"
echo -e "==========================" 
python3 $AGENT_HOME/bond/us-10-bond-yield.py

echo -e "\nUSD to NTD Exchange Rate"
echo -e "=========================="
python3 $AGENT_HOME/currency/usd_to_ntd_exchange.py

echo -e "\nTW Stock(ALL)"
echo -e "=========================="
python3 $AGENT_HOME/stock/taiwan_stock_price.py

echo -e "\nTW Stock Only"
echo -e "=========================="
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-stock.txt

echo -e "\nTW Stock (Bond EFT)"
echo -e "=========================="
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-bond.txt

echo -e "\nTW Stock (2345)"
echo -e "==========================" 
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-2345.txt

echo -e "\nTW Stock (5770)"
echo -e "=========================="
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-5770.txt

# Send report
if [ x"$1" == "x-m" ]; then
  python3 $AGENT_HOME/sendmail-ses.py -f $OUTPUT -m $RECIPIENT
fi

# clean up
# rm -f $OUTPUT
