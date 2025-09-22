#' Check Purple Air API Key
#'
#' Use the PurpleAir API to validate your Purple Air API Key.
#' Find more details on this function at https://api.purpleair.com/#api-keys-check-api-key.
#' Storing your key in the environment variable `PURPLE_AIR_API_KEY` is safer than storing it
#' in source code and is used by default in each PurpleAir function.
#' @param purple_air_api_key A character that is your PurpleAir API `READ` key
#' @returns If the key is valid, a message is emitted and the input is invisibly returned;
#' invalid keys will throw an R error which utilizes information from the underlying http error
#' to inform the user.
#' @export
#' @seealso get_organization_data
#' @examples
#' \dontrun{
#' check_api_key()
#' try(check_api_key("foofy"))
#' }
check_api_key <- function(
  purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY")
) {
  resp <- purple_air_request(
    purple_air_api_key = purple_air_api_key,
    resource = "keys",
    success_code = as.integer(200)
  ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  cli::cli_alert_success(c(
    "Using valid '{resp$api_key_type}' key ",
    "with version {resp$api_version} ",
    "of the PurpleAir API on ",
    as.POSIXct(resp$time_stamp)
  ))
  return(invisible(purple_air_api_key))
}
