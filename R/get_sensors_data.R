#' Get Sensors Data
#'
#' Retrieves the latest data of multiple sensors matching the provided parameters.
#' Find more details on sensor fields at https://api.purpleair.com/#api-sensors-get-sensors-data.
#' @param x an input object used to define multiple sensors:
#' - an integer (or numeric or character) vector will select sensors based on `sensor_index` (API: `show_only`)
#' - a st_bbox object will select sensors geographically (API: `nwlat`, `nwlon`, `selat`, `selon`)
#' - a POSIXct object will select sensors modified since the given time (API: `modified_since`)
#' @param fields A character vector of which 'sensor data fields' to return
#' @param location_type character; restrict to only "outside" or "inside" sensors (Outside: 0, Inside: 1)
#' @param max_age integer; filter results to only include sensors modified or updated within the last number of seconds
#' @param purple_air_api_key Your PurpleAir API `READ` key
#' @param read_keys A character vector of keys required to read data from private devices
#' @returns A list of sensor data, named by the provided `fields`
#' @export
#' @seealso get_sensor_data
#' @examples
#' \dontrun{
#' # get sensors data by integer, numeric, or character vector of `sensor_index`
#' get_sensors_data(
#'   x = as.integer(c(175257, 175413)),
#'   fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm")
#' )
#' get_sensors_data(
#'   x = c(175257, 175413),
#'   fields = c("name", "last_seen", "pm2.5_cf_1", "pm2.5_atm")
#' )
#' get_sensors_data(
#'   x = c("175257", "175413"),
#'   fields = c("name"), location_type = "outside"
#' )
#' # get sensors by bounding box around Hamilton County, OH
#' sf::st_bbox(c("xmin" = -84.82030, "ymin" = 39.02153,
#'               "xmax" = -84.25633, "ymax" = 39.31206),
#'             crs = 4326) |>
#'   get_sensors_data(fields = c("name"))
#' # sensors modified in the last 60 seconds
#' get_sensors_data(as.POSIXct(Sys.time()) - 60, fields = "name")
#' }
get_sensors_data <- function(x,
                             fields,
                             location_type = c("both", "inside", "outside"),
                             max_age = as.integer(604800),
                             purple_air_api_key = Sys.getenv("PURPLE_AIR_API_KEY"),
                             read_keys = NULL) {
  if (!rlang::is_character(fields)) cli::cli_abort("fields must be a character")
  if (!rlang::is_integer(max_age)) cli::cli_abort("max_age must be an integer")
  location_type <- rlang::arg_match(location_type)
  location_type <- dplyr::case_when(
    location_type == "outside" ~ 0,
    location_type == "inside" ~ 1
  )
  if (is.na(location_type)) location_type <- NULL
  if (inherits(x, c("integer", "numeric", "character"))) {
    the_req <-
      purple_air_request(
        show_only = as.integer(x),
        max_age = max_age,
        location_type = location_type,
        resource = "sensors",
        success_code = as.integer(200),
        fields = fields,
        read_keys = read_keys
      )
  }
  if (inherits(x, "bbox")) {
    rlang::check_installed("sf")
    if (!sf::st_crs(x) == sf::st_crs(4326)) {
      cli::cli_warn("Reprojecting bbox to WGS 84 projection.")
      x <- sf::st_bbox(sf::st_transform(sf::st_as_sfc(x), 4326))
    }
    the_req <-
      purple_air_request(
        max_age = max_age,
        location_type = location_type,
        nwlat = as.numeric(x[1]),
        nwlng = as.numeric(x[2]),
        selat = as.numeric(x[3]),
        selng = as.numeric(x[4]),
        resource = "sensors",
        success_code = as.integer(200),
        fields = fields,
        read_keys = read_keys
      )
  }
  if (inherits(x, "POSIXct")) {
    the_req <-
      purple_air_request(
        modified_since = as.numeric(x),
        max_age = max_age,
        location_type = location_type,
        resource = "sensors",
        success_code = as.integer(200),
        fields = fields,
        read_keys = read_keys
      )
  }
  resp <-
    the_req |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  out <-
    purrr::map(resp$data, stats::setNames, resp$fields) |>
    purrr::modify(as.data.frame) |>
    purrr::list_rbind() |>
    tibble::as_tibble()
  if ("last_seen" %in% resp$fields) out$last_seen <- as.POSIXct.numeric(out$last_seen)
  return(out)
}
