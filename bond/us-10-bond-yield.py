import requests
import os

def read_api_key(file_path):
    """Read the API key from a file"""
    with open(file_path, 'r') as file:
        return file.readline().strip()

def get_recent_us_10yr_bond_yield(api_key):
    """Get the most recent US 10-year bond yield rate using Alpha Vantage API"""
    url = f"https://www.alphavantage.co/query?function=TREASURY_YIELD&interval=daily&maturity=10year&apikey={api_key}"
    response = requests.get(url)
    data = response.json()
    
    if "data" in data:
        latest_data = data["data"][0]
        yield_rate = latest_data["value"]
        date = latest_data["date"]
        print(f"US 10-Year Bond Yield Rate on {date}: {yield_rate}%")
    else:
        print("Error retrieving data:", data.get("Note", "Unknown error"))

if __name__ == '__main__':
    # Path to the file containing the API key
    api_key_file = os.path.expanduser("~/.ssh/alpha-vantage.txt")
    api_key = read_api_key(api_key_file)
    get_recent_us_10yr_bond_yield(api_key)
