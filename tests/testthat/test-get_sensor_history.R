test_that("get_sensor_history works", {
  skip_on_os(c("windows", "linux", "solaris"))
  skip_on_cran()
  testthat::skip_if_offline()
  testthat::skip_if(Sys.getenv("PURPLE_AIR_API_KEY") == "", "no PurpleAir API key present")
  get_sensor_history(
    sensor_index = 175413,
    fields = c("pm1.0_cf_1", "pm1.0_atm", "pm2.5_cf_1", "pm2.5_atm"),
    start_timestamp = as.POSIXct("2024-07-02"),
    end_timestamp = as.POSIXct("2024-07-05")
  ) |>
    expect_s3_class("tbl_df")
})

test_that("get_sensor_history rejects invalid sensor indices before requesting", {
  expect_error(
    get_sensor_history(
      sensor_index = 175413.9,
      fields = "pm2.5_atm",
      start_timestamp = as.POSIXct("2024-07-02"),
      end_timestamp = as.POSIXct("2024-07-03")
    ),
    "whole-number sensor indices"
  )
  expect_error(
    get_sensor_history(
      sensor_index = "abc",
      fields = "pm2.5_atm",
      start_timestamp = as.POSIXct("2024-07-02"),
      end_timestamp = as.POSIXct("2024-07-03")
    ),
    "integer-like sensor indices"
  )
})

test_that("get_sensor_history maps 1week average to the API value", {
  request_average <- NULL

  testthat::local_mocked_bindings(
    purple_air_request = function(..., average) {
      request_average <<- average
      list()
    },
    .env = environment(get_sensor_history)
  )
  testthat::local_mocked_bindings(
    req_perform = identity,
    resp_body_json = function(resp) {
      force(resp)
      list(
        fields = c("time_stamp", "pm2.5_atm"),
        data = list(list(1719878400, 5.5))
      )
    },
    .package = "httr2"
  )

  out <- get_sensor_history(
    sensor_index = 175413,
    fields = "pm2.5_atm",
    start_timestamp = as.POSIXct("2024-07-02", tz = "UTC"),
    end_timestamp = as.POSIXct("2024-07-09", tz = "UTC"),
    average = "1week"
  )

  expect_identical(request_average, 10080L)
  expect_s3_class(out, "tbl_df")
})
