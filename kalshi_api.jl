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


