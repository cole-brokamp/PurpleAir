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

test_that("parse_sensor_history_response drops malformed rows", {
  resp <- list(
    fields = c("time_stamp", "pm2.5_atm"),
    data = list(
      list(1700000000, 5.1),
      list(1700000600),
      list(1700001200, 5.8)
    )
  )

  expect_warning(
    out <- parse_sensor_history_response(resp),
    "malformed rows"
  )

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 2)
  expect_equal(names(out), c("time_stamp", "pm2.5_atm"))
})

test_that("parse_sensor_history_response returns empty tibble when all rows are malformed", {
  resp <- list(
    fields = c("time_stamp", "pm2.5_atm"),
    data = list(
      list(1700000000),
      list(1700000600)
    )
  )

  expect_warning(
    out <- parse_sensor_history_response(resp),
    "malformed rows"
  )

  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 0)
  expect_equal(names(out), c("time_stamp", "pm2.5_atm"))
})
