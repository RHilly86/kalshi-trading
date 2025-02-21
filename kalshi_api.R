library(httr2)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(tibble)

source("helpers.R")

get_portfolio_balance <- function() {
  base_url <- "https://api.elections.kalshi.com"
   
  path <- "/trade-api/v2/portfolio/balance"
  headers <- create_headers("GET", path)
  req <- http_build(base_url, path, headers)
  resp <- http_run(req)
  
  balance <- resp$balance / 100
  return(balance)
}

get_events <- function(limit = 100, with_nested_markets = TRUE) {
  base_url <- "https://api.elections.kalshi.com"
  
  path <- "/trade-api/v2/events"
  headers <- create_headers("GET", path)
  query_params <- list(limit = limit, with_nested_markets = with_nested_markets)
  req <- http_build(base_url, path, headers, query_params)
  resp <- http_run(req)
  
  events <- map(resp$events, tibble::as_tibble)
  events <- 
    events |> bind_rows() |> 
    select(-c(event_ticker, title, category)) |> 
    unnest_wider(markets)
  return(events)
}

get_event <- function(event_ticker, with_nested_markets = TRUE) {
  base_url <- "https://api.elections.kalshi.com"
  
  path <- str_glue("/trade-api/v2/events/{event_ticker}")
  headers <- create_headers("GET", path)
  query_params <- list(with_nested_markets = with_nested_markets)
  req <- http_build(base_url, path, headers, query_params)
  resp <- http_run(req)
  
  event <- 
    as_tibble(resp$event) |> 
    # TODO: probably am dropping the wrong title
    select(-c(event_ticker, title, category)) |> 
    unnest_wider(markets)
  return(event)
}

resp <- get_event("KXCABCOUNT-25MAR01", with_nested_markets = TRUE)

next_req <- function(resp, req) {
    cursor <- resp_body_json(resp)$cursor
    if (cursor == "")
      return(NULL)
    req |> req_url_query(cursor = cursor)
}

get_trades <- function(limit = 100,
                       market_ticker) {
  base_url <- "https://api.elections.kalshi.com"
  
  path <- str_glue("/trade-api/v2/markets/trades")
  headers <- create_headers("GET", path)
  query_params <- list(
    limit = limit,
    ticker = market_ticker
  )
  
  req <- http_build(base_url, path, headers, query_params)
  resp <- req_perform_iterative(
    req,
    next_req,
    max_reqs = Inf
  )
  trades <- resps_data(resp, function(resp) {
    data <- resp_body_json(resp)$trades
    map(data, as_tibble)
  }) |> 
    bind_rows()
  return(trades)
} 

resp <- get_trades(1000, "KXCABCOUNT-25MAR01-15")

resp |> 
  mutate(created_time = lubridate::as_datetime(created_time)) |>
  
  
