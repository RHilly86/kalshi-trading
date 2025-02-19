import requests
import datetime
from crypto_utils import load_private_key_from_file, sign_pss_text
import polars as pl
import json

def get_timestamp():
    current_time = datetime.datetime.now()
    timestamp = current_time.timestamp()
    return str(int(timestamp * 1000))

def create_headers(private_key, access_key, method: str, path: str):
    timestamp = get_timestamp()
    msg_string = timestamp + method + path
    signature = sign_pss_text(private_key, msg_string)

    headers =  {
        'KALSHI-ACCESS-KEY': access_key,
        'KALSHI-ACCESS-SIGNATURE': signature,
        'KALSHI-ACCESS-TIMESTAMP': timestamp
    }
    return headers

def get_portfolio_balance(private_key_path: str, access_key: str):
    base_url = "https://api.elections.kalshi.com"
    private_key = load_private_key_from_file(private_key_path)
    
    path = "/trade-api/v2/portfolio/balance"
    headers = create_headers(private_key, access_key, "GET", path)
    response = requests.get(base_url + path, headers=headers)
    return response

def get_event(private_key_path: str, access_key: str, event_ticker: str, with_nested_markets: bool=True):
    base_url = "https://api.elections.kalshi.com"
    private_key = load_private_key_from_file(private_key_path)

    path = f"/trade-api/v2/events/{event_ticker}"
    headers = create_headers(private_key, access_key, "GET", path)
    params = {"with_nested_markets": with_nested_markets}
    response = requests.get(base_url + path, headers=headers, params=params)
    return response

def get_events(private_key_path: str,
               access_key: str,
               limit: int=100,
               series_ticker: str=None,
               status: str=None,
               with_nested_markets: bool=True):
    base_url = "https://api.elections.kalshi.com"
    private_key = load_private_key_from_file(private_key_path)

    path = "/trade-api/v2/events"
    headers = create_headers(private_key, access_key, "GET", path)
    params = {"with_nested_markets": with_nested_markets, "status": status, "series_ticker": series_ticker,
              "limit": limit}
    response = requests.get(base_url + path, headers=headers, params=params)
    return response

resp = get_events(private_key_path="/Users/rhilly/market-trading.txt",
           access_key="d8a1aef2-e376-4ba0-8a54-ada12eb1729b",
           limit=200)

pl.from_records(json.loads(resp.text)["events"], strict=False)

resp = get_event(private_key_path="/Users/rhilly/market-trading.txt",
          access_key="d8a1aef2-e376-4ba0-8a54-ada12eb1729b",
          event_ticker="KXVOTETULSI-26")

private_key = load_private_key_from_file("/Users/rhilly/market-trading.txt")
sign_pss_text(private_key, "mina")

pl.DataFrame(json.loads(resp.content)["event"]["markets"])