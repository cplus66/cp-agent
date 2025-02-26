#!/bin/bash -x
OUTPUT=attachment.txt

python bond/us-10-bond-yield.py | tee $OUTPUT
python currency/usd_to_ntd_exchange.py | tee -a $OUTPUT
python stock/taiwan_stock_price.py | tee -a $OUTPUT
