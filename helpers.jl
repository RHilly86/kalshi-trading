using PyCall
using Dates: time

@pyinclude("auth.py")
current_time() = string(floor(Int, time() * 1000))

function create_headers(method, path)
    # TODO: Make an environment variable to pull these in
    private_key = py"load_private_key_from_file"("/Users/rhilly/market-trading.txt")
    access_key = "d8a1aef2-e376-4ba0-8a54-ada12eb1729b"

    time = current_time()
    message = time * method * path
    signature = py"sign_pss_text"(private_key, message)

    headers = Dict(
        "KALSHI-ACCESS-KEY" => access_key,
        "KALSHI-ACCESS-SIGNATURE" => signature,
        "KALSHI-ACCESS-TIMESTAMP" => time
    )
    return headers
end





