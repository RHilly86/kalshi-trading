library(httr2)
box::use(purrr[compose], reticulate[source_python])
source_python("crypto_utils.py")

current_time <- function() {
  time <- as.numeric(Sys.time()) * 1000
  time <- as.character(bit64::as.integer64(time))
  return(time)
}

create_headers <- function(method, path) {
  # TODO: Make the environment variables persistent
  private_key <- load_private_key_from_file(Sys.getenv("KALSHI_RSA_KEY_PATH"))
  access_key <- Sys.getenv("KALSHI_API_ACCESS_KEY")
  
  time <- current_time()
  message <- paste0(time, method, path)
  signature <- sign_pss_text(private_key, message)
  
  headers <- list(
    "KALSHI-ACCESS-KEY" = access_key,
    "KALSHI-ACCESS-SIGNATURE" = signature,
    "KALSHI-ACCESS-TIMESTAMP" = time
  )
  return(headers)
}

http_build <- function(base_url,
                       path,
                       headers,
                       query_params = NULL) {
  req <- 
    request(base_url) |> 
    req_url_path_append(path) |> 
    req_headers(!!!headers)
  
  if (!is.null(query_params)) {
    req <- req |> req_url_query(!!!query_params)
  }
  return(req)
}

http_run <- compose(resp_body_json, req_perform)