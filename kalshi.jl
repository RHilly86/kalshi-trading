using DataFrames
using Chain
using HTTP
using Base64
using SHA
using Dates
using StringEncodings

struct Kalshi
    key_id::String
    private_key::String # potentially want this to be an IO buffer? idk
end




# TODO: Clean this up lol
ctx = decode(codeunits(base64encode(sha256(read("market-trading.txt")))), "utf-8")

current_time = Dates.now()
timestamp_str = string(Dates.datetime2epochms(current_time))
method = "GET"
base_url = "https://trading-api.kalshi.com"
api_url = "/trade-api/v2/exchange/status"

msg_string = timestamp_str * method * api_url

headers = Dict(
    "KALSHI-ACCESS-KEY" => "d8a1aef2-e376-4ba0-8a54-ada12eb1729b",
    "KALSHI-ACCESS-TIMESTAMP" => timestamp_str,
    "KALSHI-ACCESS-SIGNATURE" => ctx,
    "accept" => "application/json"
)

resp = HTTP.get(base_url * api_url, headers)
