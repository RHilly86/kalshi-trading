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

function get_events(limit::Int = 100, with_nested_markets::Bool = true, all_events::Bool = true)
    base_url = "https://api.elections.kalshi.com"
    path = "/trade-api/v2/events"
    headers = create_headers("GET", path)
    query_params = Dict{String, Any}("limit" => limit, "with_nested_markets" => with_nested_markets) 

    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    events = JSON3.read(decode(resp.body, "UTF-8"))

    if all_events
        data = paginate(base_url, path, headers, query_params, events, :events)
        return data
    end
    return events
end


function get_event(event_ticker::String, with_nested_markets::Bool = true)
    base_url = "https://api.elections.kalshi.com"

    path = "/trade-api/v2/events/$event_ticker"
    headers = create_headers("GET", path)
    query_params = Dict("with_nested_markets" => with_nested_markets)
    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    event = JSON3.read(decode(resp.body, "UTF-8"))
    return event[:event]
end


function get_trades(market_ticker::String, limit::Int = 1000, all_trades::Bool = true)::DataFrame
    base_url = "https://api.elections.kalshi.com"
    path = "/trade-api/v2/markets/trades"
    headers = create_headers("GET", path)
    query_params = Dict{String, Any}("limit" => limit, "ticker" => market_ticker)

    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    trades = JSON3.read(decode(resp.body, "UTF-8"))

    if all_trades
        data = paginate(base_url, path, headers, query_params, trades, :trades)
        data = DataFrame(reduce(vcat, data))
        return data
    end
    return DataFrame(trades)
end

function get_orderbook(market_ticker::String, depth::Int = 99)
    base_url = "https://api.elections.kalshi.com"
    path = "/trade-api/v2/markets/$market_ticker/orderbook"
    headers = create_headers("GET", path)
    query_params = Dict("depth" => depth)

    resp = HTTP.get(base_url * path; headers = headers, query = query_params)
    orderbook = JSON3.read(decode(resp.body, "UTF-8"))
    return orderbook[:orderbook]
end

function sort_orderbook(orderbook)
    orderbook = sort(collect(orderbook), by = x -> x[1])
    return orderbook
end

function separate_orderbook(orderbook)
    yes_side = orderbook[:yes]
    no_side = orderbook[:no]

    yes_side_price = map(x -> x[1], yes_side)
    yes_side_contracts = map(x -> x[2], yes_side)

    no_side_price = map(x -> x[1], no_side)
    no_side_contracts = map(x -> x[2], no_side)

    yes_side = sort_orderbook(Dict(zip(yes_side_price, yes_side_contracts)))
    no_side = sort_orderbook(Dict(zip(no_side_price, no_side_contracts)))

    return yes_side, no_side
end

gallego_yes, gallego_no = separate_orderbook(gallego_orderbook)

gallego_yes
gallego_no