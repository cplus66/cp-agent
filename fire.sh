#!/bin/bash
RECIPIENT=cplus.shen@gmail.com

PATH=$HOME/venv/bin:$PATH
AGENT_HOME=$(dirname $0)
AGENT_DATA=$AGENT_HOME/data
AGENT_LOG=$AGENT_HOME/log
OUTPUT=$AGENT_DATA/attachment.txt

mkdir -p $AGENT_DATA
mkdir -p $AGENT_LOG

usage()
{
  echo "./fire.sh [-m]"
}

create_summary_csv_header()
{
  echo "name,value" > $AGENT_DATA/summary.csv
}

exec &> >(tee "$OUTPUT")

echo -e "$(date)" 

create_summary_csv_header

echo -e "\nUS 10 Year Bond Yield Rate"
echo -e "======================================================================"
python3 $AGENT_HOME/bond/us-10-bond-yield.py

echo -e "\nUSD to NTD Exchange Rate"
echo -e "======================================================================"
python3 $AGENT_HOME/currency/usd_to_ntd_exchange.py | tee $AGENT_DATA/usd-to-ntd-tmp.txt
awk '{print $9}' $AGENT_DATA/usd-to-ntd-tmp.txt | tee $AGENT_DATA/usd-to-ntd.txt

echo -e "\nTW Stock(ALL)"
echo -e "======================================================================"
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config.txt -o $AGENT_DATA/stock.csv

echo -e "\nTW Stock Only"
echo -e "======================================================================"
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-stock.txt -o $AGENT_DATA/stock_only.csv

echo -e "\nTW Stock (Bond ETF)"
echo -e "======================================================================"
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-bond.txt -o $AGENT_DATA/bond_etf.csv

echo -e "\nTW Stock Yield Rate"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/earning.csv $AGENT_DATA > /dev/null
python3 $AGENT_HOME/stock/stock_yield_rate.py $AGENT_DATA/stock.csv $AGENT_DATA/earning.csv $AGENT_DATA/rate.csv

echo -e "\nUS Bond Yield Rate"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/bond.csv $AGENT_DATA > /dev/null
python3 $AGENT_HOME/bond/interest.py -f $AGENT_DATA/bond.csv -o $AGENT_DATA/bond-interest.csv \
	-c $AGENT_DATA/usd-to-ntd.txt -s $AGENT_DATA/summary.csv

# Send report
if [ x"$1" == "x-m" ]; then
  python3 $AGENT_HOME/sendmail-ses.py -f $OUTPUT -m $RECIPIENT
fi

# clean up
rm -f $OUTPUT
rm -f $AGENT_DATA/usd-to-ntd-tmp.txt
