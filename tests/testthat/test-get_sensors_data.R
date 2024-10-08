test_that("get_sensors_data works", {
  skip_on_os(c("windows", "linux", "solaris"))
  testthat::skip_if_offline()
  testthat::skip_if(Sys.getenv("PURPLE_AIR_API_KEY") == "", "no PurpleAir API key present")
  skip_on_cran()
  get_sensors_data(x = as.integer(c(175257, 175413)), fields = c("name")) |>
    expect_identical(
      tibble::tibble(
        sensor_index = as.integer(c(175257, 175413)),
        name = c("Lillard", "JN-Clifton,OH")
      )
    )

  d_bb <-
    sf::st_bbox(
    c(
      "xmin" = -84.82030,
      "ymin" = 39.02153,
      "xmax" = -84.25633,
      "ymax" = 39.31206
    ),
    crs = 4326
  ) |>
    get_sensors_data(fields = c("name"))

  expect_true("woolper" %in% d_bb$name)
  
  # sensors modified in the last 60 seconds
  get_sensors_data(as.POSIXct(Sys.time()) - 60, fields = "name") |>
    expect_s3_class("tbl_df")
})
