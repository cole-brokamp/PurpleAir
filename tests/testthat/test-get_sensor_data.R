test_that("get_sensor_data works", {
  c(
    get_sensor_data(175413, fields = "name"),
    get_sensor_data(as.integer(175413), fields = "name"),
    get_sensor_data("175413", fields = "name")
  ) |>
    expect_identical(list(name = "JN-Clifton,OH", name = "JN-Clifton,OH", name = "JN-Clifton,OH"))
})
