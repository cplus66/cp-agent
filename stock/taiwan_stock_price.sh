#!/bin/bash

# Define the path to the config file
CONFIG_FILE="config.txt"

# Check if the config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Read stock symbols from the config file
stock_symbols=$(cat "$CONFIG_FILE")

# Loop through each stock symbol and query Yahoo Finance
for symbol in $stock_symbols; do
    # Query Yahoo Finance API using curl
    response=$(curl -s "https://query1.finance.yahoo.com/v8/finance/chart/${symbol}")

    # Check if the response contains the required data
    if echo "$response" | grep -q '"chart":{"result"'; then
        # Extract the latest price and time from the JSON response
        latest_price=$(echo "$response" | jq -r '.chart.result[0].meta.regularMarketPrice')
        latest_time=$(echo "$response" | jq -r '.chart.result[0].meta.regularMarketTime')
        
        # Convert Unix timestamp to human-readable format
        latest_time_formatted=$(date -u -d @"$latest_time" +"%Y-%m-%d %H:%M:%S")
        
        # Print the latest price and time
        echo "Latest price for ${symbol}: ${latest_price} TWD at ${latest_time_formatted}"
    else
        echo "Error retrieving data for ${symbol} from Yahoo Finance: Unknown error"
    fi
done
