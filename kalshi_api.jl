using HTTP
using Base64
using StringEncodings
using JSON3

include("helpers.jl")

function get_portfolio_balance()
    base_url = "https://api.elections.kalshi.com"

    path = "/trade-api/v2/portfolio/balance"
    headers = create_headers("GET", path)
    resp = HTTP.get(base_url * path; headers=headers)
    portfolio = JSON3.read(decode(resp.body, "UTF-8"))
    return portfolio[:balance] / 100
end

resp = get_portfolio_balance()

function get_events(limit = 100, with_nested_markets = true)
    base_url = "https://api.elections.kalshi.com"
    path = "/trade-api/v2/events"
    headers = create_headers("GET", path)
    query_params = Dict("limit" => limit, "with_nested_markets" => with_nested_markets) 

    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    events = JSON3.read(decode(resp.body, "UTF-8"))
    return events[:events]
end

function get_event(event_ticker, with_nested_markets = true)
    base_url = "https://api.elections.kalshi.com"

    path = "/trade-api/v2/events/$event_ticker"
    headers = create_headers("GET", path)
    query_params = Dict("with_nested_markets" => with_nested_markets)
    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    event = JSON3.read(decode(resp.body, "UTF-8"))
    return event[:event]
end

function get_trades(limit = 1000, market_ticker)
    base_url = "https://api.elections.kalshi.com"
    path = "/trade/api/v2/markets/trades"
    headers = create_headers("GET", path)
    query_params = Dict("limit" => limit, "ticker" => market_ticker)

    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    trades = JSON3.read(decode(resp.body, "UTF-8"))
    return trades[:trades]
end


