test_that("get_sensors_data works", {
  get_sensors_data(x = as.integer(c(175257, 175413)), fields = c("name")) |>
    expect_identical(
      tibble::tibble(
        sensor_index = as.integer(c(175257, 175413)),
        name = c("Lillard", "JN-Clifton,OH")
      )
    )
})
