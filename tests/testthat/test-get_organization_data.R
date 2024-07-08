test_that("get_organization_data works", {
  skip_on_os(c("windows", "linux", "solaris"))
  testthat::skip_if_offline()
  testthat::skip_if(Sys.getenv("PURPLE_AIR_API_KEY") == "", "no PurpleAir API key present")
  skip_on_cran()
  od <- get_organization_data()
  expect_equal(od$organization_name, "Organization Cole Brokamp C8A17F7C")
})
