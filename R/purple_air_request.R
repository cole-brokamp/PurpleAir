purple_air_request <- function(
  purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY"),
  resource = c("keys", "organization", "sensors", "sensor_history"),
  sensor_index = NULL,
  success_code,
  ...
) {
  if (!rlang::is_integer(success_code))
    cli::cli_abort("success_code must be an integer")
  resource <- rlang::arg_match(resource)
  req <-
    httr2::request("https://api.purpleair.com/v1") |>
    httr2::req_user_agent(
      "PurpleAir package for R (https://github.com/cole-brokamp/PurpleAir)"
    ) |>
    httr2::req_headers(
      "X-API-Key" = purple_air_api_key,
      .redact = "X-API-Key"
    ) |>
    httr2::req_error(
      is_error = \(resp) httr2::resp_status(resp) != success_code,
      body = \(resp)
        glue::glue_data(
          httr2::resp_body_json(resp),
          "{error}: {description} (API version: {api_version})"
        )
    ) |>
    httr2::req_url_query(!!!list(...), .multi = "comma") |>
    httr2::req_retry(
      max_seconds = as.numeric(Sys.getenv(
        "PURPLE_AIR_API_RETRY_MAX_TIME",
        "45"
      ))
    )
  if (resource == "keys") {
    req <- httr2::req_url_path_append(req, "keys")
  }
  if (resource == "organization") {
    req <- httr2::req_url_path_append(req, "organization")
  }
  if (resource == "sensors") {
    req <- httr2::req_url_path_append(req, "sensors")
    if (!is.null(sensor_index)) {
      req <- httr2::req_url_path_append(req, sensor_index)
    }
  }
  if (resource == "sensor_history")
    req <- httr2::req_url_path_append(req, "sensors", sensor_index, "history")
  return(req)
}
