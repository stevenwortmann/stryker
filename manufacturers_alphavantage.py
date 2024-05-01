import requests

def get_financials(api_key, symbol):
    base_url = "https://www.alphavantage.co/query"
    params = {
        "function": "INCOME_STATEMENT",
        "symbol": symbol,
        "apikey": api_key
    }
    response = requests.get(base_url, params=params)
    data = response.json()
    return data

# Example usage:
api_key = 'your_alpha_vantage_api_key'
company_symbol = 'HON'  # Example: Honeywell International Inc
financials = get_financials(api_key, company_symbol)
