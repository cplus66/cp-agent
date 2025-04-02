#!/bin/bash
# Date: Mar 27, 2025
# Author: cplus.shen
# Description: Asset calculator
#
# Input
# - in-tw-stock-all.csv
# - in-tw-stock-only.csv
# - in-tw-stock-etf.csv
# - in-us-bond.csv
# - in-tw-cash-fixed.csv
# - in-us-cash-fixed.csv
# - in-tw-cash.csv
#
# Output
# - out-tw-total-asset.csv
#   - out-tw-stock-all.csv
#   - out-us-bond.csv
#   - out-tw-cash-fixed.csv
#   - out-us-cash-fixed.csv
#   - out-tw-cash.csv
#
# - out-tw-total-interest.csv
#   - out-tw-interest-stock.csv
#   - out-us-interest-bond.csv
#   - out-tw-interest-fixed.csv
#   - out-us-interest-fixed.csv

RECIPIENT=cplus.shen@gmail.com

PATH=$HOME/venv/bin:$PATH
AGENT_HOME=$(dirname $0)
AGENT_DATA=$AGENT_HOME/data

OUTPUT=$AGENT_DATA/attachment.txt
AGENT_LOG=$AGENT_HOME/log

OUTPUT_SUBTOTAL_ASSET=$AGENT_DATA/subtotal-asset.csv
OUTPUT_SUBTOTAL_ASSET_STOCK=$AGENT_DATA/subtotal-asset-stock.csv
OUTPUT_SUBTOTAL_ASSET_BOND=$AGENT_DATA/subtotal-asset-bond.csv
OUTPUT_SUBTOTAL_ASSET_CASH=$AGENT_DATA/subtotal-asset-cash.csv
OUTPUT_SUBTOTAL_INTEREST=$AGENT_DATA/subtotal-interest.csv
OUTPUT_TOTAL_ASSET=$AGENT_DATA/total-asset.csv
OUTPUT_TOTAL_INTEREST=$AGENT_DATA/total-interest.csv

usage()
{
  echo "./fire.sh [-m]"
}

prepare()
{
  mkdir -p $AGENT_DATA
  mkdir -p $AGENT_LOG
}


create_summary_csv_header()
{
  echo "name,value" > $OUTPUT_SUBTOTAL_ASSET
  echo "name,value" > $OUTPUT_SUBTOTAL_ASSET_STOCK
  echo "name,value" > $OUTPUT_SUBTOTAL_ASSET_BOND
  echo "name,value" > $OUTPUT_SUBTOTAL_ASSET_CASH
  echo "name,value" > $OUTPUT_SUBTOTAL_INTEREST
}

is_usd_to_ntd_empty()
{
  SIZE=$(wc $AGENT_DATA/usd-to-ntd.txt | awk '{print $3}')

  if [ x$SIZE == "x1" ]; then
    return 1
  else
    return 0
  fi
}

exec &> >(tee "$OUTPUT")

echo -e "$(date)" 

prepare
create_summary_csv_header

echo -e "\nUS 10 Year Bond Yield Rate"
echo -e "======================================================================"
python3 $AGENT_HOME/bond/us-10-bond-yield.py

echo -e "\nUSD to NTD Exchange Rate"
echo -e "======================================================================"
python3 $AGENT_HOME/currency/usd_to_ntd_exchange.py | tee $AGENT_DATA/usd-to-ntd-tmp.txt
awk '{print $9}' $AGENT_DATA/usd-to-ntd-tmp.txt | tee $AGENT_DATA/usd-to-ntd.txt

if [ is_usd_to_ntd_empty ]; then
  echo "33.20" > $AGENT_DATA/usd-to-ntd.txt
fi

#
# Asset (Stock, Bond, Cash)
#

echo -e "\nTW Stock(ALL)"
echo -e "======================================================================"
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config.txt -o $AGENT_DATA/stock.csv \
	-s $OUTPUT_SUBTOTAL_ASSET

echo -e "\nTW Stock Only"
echo -e "======================================================================"
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-stock.txt -o $AGENT_DATA/stock_only.csv \
	-s $OUTPUT_SUBTOTAL_ASSET_STOCK

echo -e "\nTW Stock (Bond ETF)"
echo -e "======================================================================"
python3 $AGENT_HOME/stock/taiwan_stock_price.py -c config-bond.txt -o $AGENT_DATA/bond_etf.csv \
	-s $OUTPUT_SUBTOTAL_ASSET_BOND

echo -e "\nUS Bond"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/bond.csv $AGENT_DATA > /dev/null
python3 $AGENT_HOME/bond/bond.py -f $AGENT_DATA/bond.csv -o $AGENT_DATA/bond-interest.csv \
	-c $AGENT_DATA/usd-to-ntd.txt -s $OUTPUT_SUBTOTAL_ASSET_BOND
tail -n 1 $OUTPUT_SUBTOTAL_ASSET_BOND >> $OUTPUT_SUBTOTAL_ASSET

echo -e "\nCash TW Total"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/cash.csv $AGENT_DATA > /dev/null
python $AGENT_HOME/cash/cash_tw.py -f $AGENT_DATA/cash.csv -o $AGENT_DATA/out-cash.csv \
	-s $OUTPUT_SUBTOTAL_ASSET_CASH
tail -n 1 $OUTPUT_SUBTOTAL_ASSET_CASH >> $OUTPUT_SUBTOTAL_ASSET

echo -e "\nCash TW Fixed Total"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/fixed.csv $AGENT_DATA > /dev/null
python $AGENT_HOME/cash/cash_tw.py -f $AGENT_DATA/fixed.csv -o $AGENT_DATA/out-cash.csv \
	-s $OUTPUT_SUBTOTAL_ASSET_CASH
tail -n 1 $OUTPUT_SUBTOTAL_ASSET_CASH >> $OUTPUT_SUBTOTAL_ASSET

echo -e "\nCash US Fixed Total"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/fixed-us.csv $AGENT_DATA > /dev/null
python $AGENT_HOME/cash/cash_us.py -f $AGENT_DATA/fixed-us.csv -o $AGENT_DATA/out-cash-us.csv \
	-c $AGENT_DATA/usd-to-ntd.txt -s $OUTPUT_SUBTOTAL_ASSET_CASH
tail -n 1 $OUTPUT_SUBTOTAL_ASSET_CASH >> $OUTPUT_SUBTOTAL_ASSET

#
# Yield Rate
#
echo -e "\nTW Stock Yield Rate"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/earning.csv $AGENT_DATA > /dev/null
python3 $AGENT_HOME/stock/stock_yield_rate.py $AGENT_DATA/stock.csv $AGENT_DATA/earning.csv $AGENT_DATA/rate.csv $OUTPUT_SUBTOTAL_INTEREST

echo -e "\nUS Bond Yield Rate"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/bond.csv $AGENT_DATA > /dev/null
python3 $AGENT_HOME/bond/interest.py -f $AGENT_DATA/bond.csv -o $AGENT_DATA/bond-interest.csv \
	-c $AGENT_DATA/usd-to-ntd.txt -s $OUTPUT_SUBTOTAL_INTEREST

echo -e "\nCash US Yield Rate"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/fixed-us.csv $AGENT_DATA > /dev/null
python $AGENT_HOME/cash/fixed_us.py -f $AGENT_DATA/fixed-us.csv -o $AGENT_DATA/out-fixed-us.csv \
	-c $AGENT_DATA/usd-to-ntd.txt -s $OUTPUT_SUBTOTAL_INTEREST

echo -e "\nCash TW Yield Rate"
echo -e "======================================================================"
aws s3 cp s3://prjdoc/cp-agent/fixed.csv $AGENT_DATA > /dev/null
python $AGENT_HOME/cash/fixed_tw.py -f $AGENT_DATA/fixed.csv -o $AGENT_DATA/out-fixed-tw.csv \
	-s $OUTPUT_SUBTOTAL_INTEREST

#
# Total
#
echo -e "\nTotal Asset"
echo -e "======================================================================"
python $AGENT_HOME/total/total.py -f $OUTPUT_SUBTOTAL_ASSET -o $OUTPUT_TOTAL_ASSET

echo -e "\nTotal Interest"
echo -e "======================================================================"
python $AGENT_HOME/total/total.py -f $OUTPUT_SUBTOTAL_INTEREST -o $OUTPUT_TOTAL_INTEREST

# Send report
if [ x"$1" == "x-m" ]; then
  python3 $AGENT_HOME/sendmail-ses.py -f $OUTPUT -m $RECIPIENT
fi

# clean up
rm -f $OUTPUT
rm -f $AGENT_DATA/usd-to-ntd-tmp.txt
