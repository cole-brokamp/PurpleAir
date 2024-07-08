#' get sensor history
#'
#' Retrieves the latest history of a single sensor matching the provided `sensor_index`.
#' Find more details on sensor fields at https://api.purpleair.com/#api-sensors-get-sensor-history.
#' @param sensor_index Integer (or numeric, character object coerceable to integer) `sensor_index`
#' @param fields A character vector of which 'sensor data fields' to return
#' @param start_timestamp time stamp of first required history entry (inclusive)
#' @param end_timestamp end time stamp of history to return (exclusive)
#' @param average time frame to request averaged results for
#' @param purple_air_api_key A character that is your PurpleAir API `READ` key
#' @param read_key A character key required to read data from private devices
#' @returns a list of sensor data, named by the provided `fields`
#' @export
#' @examples
#' \dontrun{
#' get_sensor_history(
#'   sensor_index = 175413,
#'   fields = c("pm1.0_cf_1", "pm1.0_atm", "pm2.5_cf_1", "pm2.5_atm"),
#'   start_timestamp = as.POSIXct("2024-07-02"),
#'   end_timestamp = as.POSIXct("2024-07-05")
#' )
#' }
get_sensor_history <- function(sensor_index,
                               fields,
                               start_timestamp,
                               end_timestamp,
                               average = c("10min", "30min", "60min",
                                           "6hr", "1day", "1week",
                                           "1month", "1year", "real-time"),
                               purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY"),
                               read_key = NULL) {
  if (!rlang::is_integer(as.integer(sensor_index))) cli::cli_abort("sensor_index must be an integer")
  if (!rlang::is_character(fields)) cli::cli_abort("fields must be a character")
  avg <- rlang::arg_match(average)
  avg_int <- as.integer(
    c(
      "real-time" = 0, "10min" = 10, "30min" = 30, "60min" = 60,
      "6hr" = 360, "1day" = 1440, "1week" = 60, "1month" = 60, "1year" = 60
    )[avg]
  )
  resp <-
    purple_air_request(
      resource = "sensor_history",
      success_code = as.integer(200),
      sensor_index = as.integer(sensor_index),
      start_timestamp = as.integer(start_timestamp),
      end_timestamp = as.integer(end_timestamp),
      average = avg_int,
      fields = fields,
      read_key = read_key
    ) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  out <-
    purrr::map(resp$data, stats::setNames, resp$fields) |>
    purrr::modify(as.data.frame) |>
    purrr::list_rbind() |>
    tibble::as_tibble()
  out$time_stamp <- as.POSIXct.numeric(out$time_stamp)
  return(out)
  ## md <- purrr::discard_at(resp, c("fields", "data"))
}
