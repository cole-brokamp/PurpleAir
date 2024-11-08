#' search a local network for purple air monitors
#' find_local_pam()
find_local_pam <- function(subnet = "192.168.1") {
  ip_list <- paste0(subnet, ".", 1:254)
  pam_ids <- purrr::map(ip_list, ip_pam_id,
    .progress = "searching local network"
  )
  out <-
    pam_ids |>
    rlang::set_names(ip_list) |>
    purrr::compact() |>
    stats::na.omit()
  return(out)
}

#' returns NULL if address doesn't respond to a SensorId request
#'
#' ip_pam_id("192.168.1.147") # purple air
#' ip_pam_id("192.168.1.148") # no server
#' ip_pam_id("192.168.1.141") # non-purple air
ip_pam_id <- function(ip_address) {
  req <-
    httr2::request(paste0("http://", ip_address, "/json")) |>
    httr2::req_timeout(1)
  resp <- tryCatch(httr2::req_perform(req), error = function(e) NULL)
  if (is.null(resp)) {
    return(NULL)
  }
  if (!httr2::resp_status(resp) == 200) {
    return(NULL)
  }
  sensor_id <- tryCatch(httr2::resp_body_json(resp)$SensorId, error = function(e) NULL)
  return(sensor_id)
}
