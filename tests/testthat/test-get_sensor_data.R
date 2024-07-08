test_that("get_sensor_data works", {
  skip_on_os(c("windows", "linux", "solaris"))
  testthat::skip_if_offline()
  testthat::skip_if(Sys.getenv("PURPLE_AIR_API_KEY") == "", "no PurpleAir API key present")
  skip_on_cran()
  c(
    get_sensor_data(175413, fields = "name"),
    get_sensor_data(as.integer(175413), fields = "name"),
    get_sensor_data("175413", fields = "name")
  ) |>
    expect_identical(list(name = "JN-Clifton,OH", name = "JN-Clifton,OH", name = "JN-Clifton,OH"))
})
