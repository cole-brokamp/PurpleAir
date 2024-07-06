#' check purple air api key
#'
#' Use the PurpleAir API to validate your Purple Air API Key.
#' Find more details on this function at https://api.purpleair.com/#api-keys-check-api-key
#' @param purple_air_api_key A character that is your PurpleAir API `READ` key
#' @returns if the key is valid, a message is emitted and the input is invisibly returned;
#' invalid keys will throw an R error which utilizes information from the underlying http error
#' to inform the user
#' @export
#' @examples
#' check_api_key()
#' try(check_api_key("foofy"))
check_api_key <- function(purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY")) {
  resp <- purple_air_request(
    purple_air_api_key = purple_air_api_key,
    resource = "keys",
    success_code = as.integer(201)
  ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  # TODO add check that is must be a `READ` type key?
  cli::cli_alert_success("Using valid '{resp$api_key_type}' key with version {resp$api_version} of the PurpleAir API on {as.POSIXct(resp$time_stamp)}")
  return(invisible(purple_air_api_key))
}
