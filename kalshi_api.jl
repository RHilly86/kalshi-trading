using HTTP
using Base64
using StringEncodings
using JSON3
using DataFrames

include("helpers.jl")

function get_portfolio_balance()
    base_url = "https://api.elections.kalshi.com"

    path = "/trade-api/v2/portfolio/balance"
    headers = create_headers("GET", path)
    resp = HTTP.get(base_url * path; headers=headers)
    portfolio = JSON3.read(decode(resp.body, "UTF-8"))
    return portfolio[:balance] / 100
end

function get_events(limit = 100, with_nested_markets = true, all_events = true)
    base_url = "https://api.elections.kalshi.com"
    path = "/trade-api/v2/events"
    headers = create_headers("GET", path)
    query_params = Dict{String, Any}("limit" => limit, "with_nested_markets" => with_nested_markets) 

    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    events = JSON3.read(decode(resp.body, "UTF-8"))

    if all_events
        data = []
        cursor = events[:cursor]
        while cursor != ""
            query_params["cursor"] = cursor
            resp = HTTP.get(base_url * path; headers = headers, query = query_params)
            events = JSON3.read(decode(resp.body, "UTF-8"))
            push!(data, events[:events])
            cursor = events[:cursor]
            println(data)
        end
    end
    return data
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

function get_trades(market_ticker, limit = 1000, all_trades = true)
    base_url = "https://api.elections.kalshi.com"
    path = "/trade-api/v2/markets/trades"
    headers = create_headers("GET", path)
    query_params = Dict{String, Any}("limit" => limit, "ticker" => market_ticker)

    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    trades = JSON3.read(decode(resp.body, "UTF-8"))

    if all_trades
        data = paginate(base_url, path, headers, query_params, trades, :trades)
    end
    return data
end

function paginate(base_url, path, headers, query_params, first_resp, field_name)
    data = []
    push!(data, first_resp[field_name])
    cursor = first_resp[:cursor]
    while cursor != ""
        query_params["cursor"] = cursor
        resp = HTTP.get(base_url * path; headers = headers, query = query_params)
        json_body = JSON3.read(decode(resp.body, "UTF-8"))
        push!(data, json_body[field_name])
        cursor = json_body[:cursor]
    end
    return data
end

x = get_trades("KXCABCOUNT-25MAR01-15")


        data = []
        push!(data, trades[:trades])
        cursor = trades[:cursor]
        while cursor != ""
            query_params["cursor"] = cursor
            resp = HTTP.get(base_url * path; headers = headers, query = query_params)
            trades = JSON3.read(decode(resp.body, "UTF-8"))
            push!(data, trades[:trades])
            cursor = trades[:cursor]
            println(data)