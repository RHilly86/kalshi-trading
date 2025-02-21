using PyCall
using HTTP
using StringEncodings: decode
using Dates: time

@pyinclude("auth.py")
current_time() = string(floor(Int, time() * 1000))

function create_headers(method, path)
    # TODO: Make an environment variable to pull these in
    private_key = py"load_private_key_from_file"(ENV["KALSHI_RSA_KEY_PATH"])
    access_key = ENV["KALSHI_API_ACCESS_KEY"]

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




