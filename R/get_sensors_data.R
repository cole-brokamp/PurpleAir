#' get sensors data
#'
#' Retrieves the latest data of multiple sensors matching the provided parameters.
#' Find more details on sensor fields at https://api.purpleair.com/#api-sensors-get-sensors-data.
#' @param x an input object used to define multiple sensors  
#' - st_bbox object will select sensors geographically (`nwlat`, `nwlon`, `selat`, `selon`)
#' - integer vector will select sensors based on `sensor_index` (`show_only`)
#' - POSIXct object will select sensors modified since then (`modified_since`)
#' @param fields A character vector of which 'sensor data fields' to return
#' @param location_type character; restrict to only "outside" or "inside" sensors (Outside: 0, Inside: 1)
#' @param max_age integer; filter results to only include sensors modified or updated within the last number of seconds
#' @param purple_air_api_key Your PurpleAir API `READ` key
#' @param read_keys TODO A character vector of keys required to read data from private devices
#' @returns a list of sensor data, named by the provided `fields`
#' @export
#' @examples
#' get_sensors_data(x = as.integer(c(175257, 175413)),
#'   fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
#' get_sensors_data(x = as.integer(c(175257, 175413)),
#'   fields = c("name", "pm2.5_cf_1", "pm2.5_atm"), location_type = "outside")
get_sensors_data <- function(x, fields, location_type = c("both", "inside", "outside"), max_age = as.integer(604800), purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY"), read_keys = NULL) {
  # TODO support multiple read keys
  if (!rlang::is_character(fields)) cli::cli_abort("fields must be a character")
  if (!rlang::is_integer(max_age)) cli::cli_abort("max_age must be an integer")
  location_type <- rlang::arg_match(location_type)
  location_type <- dplyr::case_when(
    location_type == "outside" ~ 0,
    location_type == "inside" ~ 1
  )
  if (is.na(location_type)) location_type <- NULL
  resp <-
    purple_air_request(
      show_only = paste(x, collapse = ","), # x is integer vector
      max_age = max_age,
      location_type = location_type,
      resource = "sensors",
      success_code = as.integer(200),
      fields = fields,
      read_keys = read_keys
    )
  out <-
    purrr::map(resp$data, stats::setNames, resp$fields) |>
    purrr::modify(as.data.frame) |>
    purrr::list_rbind() |>
    tibble::as_tibble()
  if ("last_seen" %in% resp$fields) out$last_seen <- as.POSIXct.numeric(out$last_seen)
  # TODO return metadata how?
  md <- purrr::discard_at(resp, c("fields", "data"))
  return(out)
}




## #' @param show_only An integer vector of `sensor_index` sensors identifiers to return
## #' @param modified_since A POSIXct time object.
## #' Only sensors modified after this time are included in the results; no effect if `show_only` is specified
