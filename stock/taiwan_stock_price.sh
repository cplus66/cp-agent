#!/bin/bash

# Define the stock symbol (e.g., "2330" for TSMC)
STOCK_SYMBOL="2395.TW"

# Query Yahoo Finance API using curl
response=$(curl -s "https://query1.finance.yahoo.com/v8/finance/chart/${STOCK_SYMBOL}")

# Check if the response contains the required data
if echo "$response" | grep -q '"chart":{"result"'; then
    # Extract the latest price and time from the JSON response
    latest_price=$(echo "$response" | jq -r '.chart.result[0].meta.regularMarketPrice')
    latest_time=$(echo "$response" | jq -r '.chart.result[0].meta.regularMarketTime')
    
    # Convert Unix timestamp to human-readable format
    latest_time_formatted=$(date -u -d @"$latest_time" +"%Y-%m-%d %H:%M:%S")
    
    # Print the latest price and time
    echo "Latest price for ${STOCK_SYMBOL}: ${latest_price} TWD at ${latest_time_formatted}"
else
    echo "Error retrieving data from Yahoo Finance: Unknown error"
fi
