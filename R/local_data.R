#' local_sensor_live
#'
#' Stream the latest data from a sensor on the local area network.
#' Data is updated every second on the device; this function waits
#' half a second after each call, which takes less than half a second,
#' ensuring sub one second updating freqency.
#' @export
#' @examples
#' local_sensor_live("192.168.1.144")
local_sensor_live <- function(ip_address) {
  sensor_id <- ip_pam_id(ip_address)
  if (is.null(sensor_id)) stop("not a purple air monitor ip_address")
  while (TRUE) {
    sensor_data <-
      httr2::request(paste0("http://", ip_address, "/json")) |>
      httr2::req_url_query(live = "true") |>
      httr2::req_perform() |>
      httr2::resp_body_json()
    Sys.sleep(.5)
    cat("pm2.5 AQI: ", sensor_data$pm2.5_aqi, " [", Sys.time(), "]\r")
    flush.console()
  }
  return(invisible(NULL))
}

#' local_sensor_data
#'
#' Get latest data (updated every two minutes) from a sensor the local area network.
#'
#' @param ip_address address of purple air monitor on local area network
#' to request data from
#' @return a list of data returned by the sensor
#' @export
#' @examples
#' local_sensor_data("192.168.1.144") |>
#'   _[c("DateTime", "current_temp_f", "current_humidity", "pm2.5_alt", "p25aqic")]
#' tictoc::tic(); local_sensor_data("192.168.1.144"); tictoc::toc()
local_sensor_data <- function(ip_address) {
  sensor_id <- ip_pam_id(ip_address)
  if (is.null(sensor_id)) stop("not a purple air monitor ip_address")
  sensor_data <-
    httr2::request(paste0("http://", ip_address, "/json")) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  updated_at <-
    as.POSIXct(sensor_data$DateTime, format = "%Y/%m/%dT%H:%M:%Sz", tz = "UTC")
  if (interactive()) message("updated ", format(updated_at, "%c"))
  sensor_data$time <- updated_at
  return(sensor_data)
}

#' find purple area monitors on a local network
#'
#' All IP addresses within the network are pinged
#' to possibly return a purple air monitor sensor ID.
#' @param network_prefix character string; base IPv4 prefix
#' (first three octets) used to generate IP addresses
#' @param timeout numeric; number of seconds to wait for each ping
#' @return a list of purple air monitor IDs named according to their IP address
#' @export
#' @examples
#' \dontrun{
#' find_local_pam()
#' }
find_local_pam <- function(
  network_prefix = "192.168.1",
  timeout = 1,
  find_multiple = FALSE
) {
  ip_list <- paste0(network_prefix, ".", 1:254)
  # local({
  #   for (ip in ip_list) {
  #     cat("checking ", ip, "\r")
  #     flush.console()
  #     ping <- ip_pam_id(ip, timeout = timeout)
  #     if (!is.null(ping)) {
  #       message("🟣 found purple air monitor: ", ping)
  #       names(ping) <- ip
  #       pam_id <<- ping
  #       break
  #     }
  #   }
  # })
  # pam_id
  pam_ids <- purrr::map(
    ip_list,
    ip_pam_id,
    timeout = timeout,
    .progress = paste0(
      "scanning ",
      network_prefix,
      ".* for purple air monitors 🟣"
    )
  )
  out <-
    pam_ids |>
    rlang::set_names(ip_list) |>
    purrr::compact() |>
    stats::na.omit()
  return(out)
}

#' get purple air monitor id from ip address
#'
#' @param ip_address character; address to send sensor id request to
#' @param timeout numeric; number of seconds to wait for each ping
#' @return NULL if address doesn't respond to a SensorId request;
#' if ip address is a purple air monitor, the monitor id is returned
#' @export
#' @examples
#' ip_pam_id("192.168.1.144") # purple air
#' ip_pam_id("192.168.1.148") # no server
#' ip_pam_id("192.168.1.141") # non-purple air
ip_pam_id <- function(ip_address, timeout = 1) {
  req <-
    httr2::request(paste0("http://", ip_address, "/json")) |>
    httr2::req_timeout(timeout)
  resp <- tryCatch(httr2::req_perform(req), error = function(e) NULL)
  if (is.null(resp)) {
    return(NULL)
  }
  if (!httr2::resp_status(resp) == 200) {
    return(NULL)
  }
  sensor_id <- tryCatch(
    httr2::resp_body_json(resp)$SensorId,
    error = function(e) NULL
  )
  return(sensor_id)
}
