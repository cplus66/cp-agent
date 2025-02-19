import requests
import csv
import time
from datetime import datetime, timezone

def get_stock_price(symbol):
    """Get the latest stock price for a given symbol using Yahoo Finance"""
    url = f"https://query1.finance.yahoo.com/v8/finance/chart/{symbol}"
    headers = {
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36"
    }
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        if "chart" in data and "result" in data["chart"] and data["chart"]["result"]:
            result = data["chart"]["result"][0]
            meta = result["meta"]
            latest_price = meta["regularMarketPrice"]
            latest_time = meta["regularMarketTime"]
            latest_time_formatted = datetime.fromtimestamp(latest_time, tz=timezone.utc).strftime('%Y-%m-%d %H:%M:%S')
            return latest_price, latest_time_formatted
        else:
            print(f"Error: No chart data found for {symbol}")
    else:
        if response.status_code == 429:
            print(f"Rate limit exceeded for {symbol}. Retrying after 60 seconds...")
            time.sleep(60)
            return get_stock_price(symbol)
        else:
            print(f"Error: Unable to retrieve data for {symbol}, status code: {response.status_code}")
    return None, None

def read_stock_symbols(file_path):
    """Read stock symbols from a CSV file"""
    with open(file_path, 'r') as file:
        reader = csv.DictReader(file)
        return [row for row in reader]

def main():
    config_file = 'config.txt'
    symbols = read_stock_symbols(config_file)
    
    for entry in symbols:
        symbol = entry['symbol']
        count = entry['count']
        typical = entry['typical']
        price, time = get_stock_price(symbol)
        if price and time:
            print(f"Latest price for {symbol}: {price} TWD at {time} (Count: {count}, Typical: {typical})")

if __name__ == '__main__':
    main()
