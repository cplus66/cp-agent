import requests
import os

def read_api_key(file_path):
    """Read the API key from a file"""
    with open(file_path, 'r') as file:
        return file.readline().strip()

def get_usd_to_ntd_exchange_rate(api_key):
    """Get the most recent USD to NTD exchange rate using Alpha Vantage API"""
    url = f"https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=TWD&apikey={api_key}"
    response = requests.get(url)
    data = response.json()
    
    if "Realtime Currency Exchange Rate" in data:
        exchange_rate = data["Realtime Currency Exchange Rate"]["5. Exchange Rate"]
        last_refreshed = data["Realtime Currency Exchange Rate"]["6. Last Refreshed"]
        print(f"USD to NTD Exchange Rate on {last_refreshed}: {exchange_rate}")
    else:
        print("Error retrieving data:", data.get("Note", "Unknown error"))

if __name__ == '__main__':
    # Path to the file containing the API key
    api_key_file = os.path.expanduser("~/.ssh/alpha-vantage.txt")
    api_key = read_api_key(api_key_file)
    get_usd_to_ntd_exchange_rate(api_key)
