#!/bin/bash -x
python bond/us-10-bond-yield.py | tee output.txt
python currency/usd_to_ntd_exchange.py | tee -a output.txt
python stock/taiwan_stock_price.py | tee -a output.txt
