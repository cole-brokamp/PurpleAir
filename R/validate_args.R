coerce_sensor_index <- function(sensor_index, arg = "sensor_index") {
  out <- coerce_sensor_indices(sensor_index, arg = arg)
  if (length(out) != 1L) {
    cli::cli_abort("{.arg {arg}} must contain exactly one sensor index")
  }
  out
}

coerce_sensor_indices <- function(sensor_indices, arg = "sensor_index") {
  if (!inherits(sensor_indices, c("integer", "numeric", "character"))) {
    cli::cli_abort(
      "{.arg {arg}} must be an integer, numeric, or character vector of sensor indices"
    )
  }

  if (length(sensor_indices) < 1L || anyNA(sensor_indices)) {
    cli::cli_abort("{.arg {arg}} must contain at least one non-missing sensor index")
  }

  if (inherits(sensor_indices, c("integer", "numeric"))) {
    if (any(!is.finite(sensor_indices)) || any(sensor_indices != trunc(sensor_indices))) {
      cli::cli_abort("{.arg {arg}} must contain whole-number sensor indices")
    }
    return(as.integer(sensor_indices))
  }

  if (any(!grepl("^[+-]?[0-9]+$", sensor_indices))) {
    cli::cli_abort("{.arg {arg}} must contain only integer-like sensor indices")
  }

  out <- suppressWarnings(as.integer(sensor_indices))
  if (anyNA(out)) {
    cli::cli_abort("{.arg {arg}} must contain only integer-like sensor indices")
  }

  out
}
