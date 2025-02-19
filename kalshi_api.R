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

get_portfolio_balance()

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

get_candlesticks <- function(market_ticker, series_ticker) {
  base_url <- "https://api.elections.kalshi.com"
  
  path <- str_glue("/trade-api/v2/series/{series_ticker}/markets/{market_ticker}/candlesticks")
  headers <- create_headers("GET", path)
  req <- http_build(base_url, path, headers)
  resp <- http_run(req)
  
  return(resp)
}

get_trades <- function(limit = 100, market_ticker) {
  base_url <- "https://api.elections.kalshi.com"
  
  path <- str_glue("/trade-api/v2/markets/trades")
  headers <- create_headers("GET", path)
  query_params <- list(
    limit = 100,
    ticker = market_ticker
  )
  req <- http_build(base_url, path, headers, query_params)
  resp <- http_run(req)
  
  return(resp)
}

resp$cursor

resp <- get_trades(100, "KXCABCOUNT-25MAR01-15")

trades <- bind_rows(map(resp$trades, as_tibble))
trades






