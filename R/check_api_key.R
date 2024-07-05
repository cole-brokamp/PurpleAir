# https://api.purpleair.com/#api-keys-check-api-key
check_api_key <- function(purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY")) {
  resp <- purple_air_request(
    purple_air_api_key = purple_air_api_key,
    resource = "keys",
    success_code = as.integer(201)
  )
  # TODO add check that is must be a `READ` type key?
  cli::cli_alert_success("Using valid '{resp$api_key_type}' key with version {resp$api_version} of the PurpleAir API on {as.POSIXlt(resp$time_stamp)}")
  return(invisible(purple_air_api_key))
}
