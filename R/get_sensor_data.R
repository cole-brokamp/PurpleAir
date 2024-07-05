#' get sensor data
#'
#' Retrieves the latest data of a single sensor matching the provided `sensor_index`.
#' Find more details on sensor fields at https://api.purpleair.com/#api-sensors-get-sensor-data.
#' @param sensor_index The `sensor_index` as found in the JSON for this specific sensor
#' @param fields A character vector of which 'sensor data fields' to return
#' @param purple_air_key Your PurpleAir API `READ` key
#' @param read_key A character key required to read data from private devices
#' @returns a list of sensor data, named by the provided `fields`
#' @export
#' @examples
#' get_sensor_data(sensor_index = as.integer(175413), fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm"))
get_sensor_data <- function(purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY"), sensor_index, fields) {
  if (!rlang::is_integer(sensor_index)) cli::cli_abort("sensor_index must be an integer")
  if (!rlang::is_character(fields)) cli::cli_abort("fields must be a character")
  resp <-
    purple_air_request(
      resource = "sensors",
      success_code = as.integer(200),
      sensor_index = sensor_index,
      fields = fields
    )
  resp$sensor$sensor_index <- NULL
  return(resp$sensor)
}
