test_that("get_sensor_data works", {
  skip_on_os(c("windows", "linux", "solaris"))
  skip_on_cran()
  c(
    get_sensor_data(175413, fields = "name"),
    get_sensor_data(as.integer(175413), fields = "name"),
    get_sensor_data("175413", fields = "name")
  ) |>
    expect_identical(list(name = "JN-Clifton,OH", name = "JN-Clifton,OH", name = "JN-Clifton,OH"))
})
