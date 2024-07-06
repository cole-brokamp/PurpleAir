#' get organization data
#'
#' Use the PurpleAir API to retrieve information for the organization containing the provided api_key
#' Find more details on this function at https://api.purpleair.com/#api-organization-get-organization-data
#' @param purple_air_api_key A character that is your PurpleAir API `READ` key
#' @returns a list of organization info
#' @export
#' @examples
#' get_organization_data()
get_organization_data <- function(purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY")) {
  resp <-
    purple_air_request(
      purple_air_api_key = purple_air_api_key,
      resource = "organization",
      success_code = as.integer(200)
    ) |>
    httr2::req_perform()
  out <- httr2::resp_body_json(resp)
  out$time_stamp <- as.POSIXct.numeric(out$time_stamp)
  return(out)
}
