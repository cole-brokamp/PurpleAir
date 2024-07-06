test_that("get_organization_data works", {
  skip_on_os(c("windows", "linux", "solaris"))
  skip_on_cran()
  od <- get_organization_data()
  expect_equal(od$organization_name, "Organization Cole Brokamp C8A17F7C")
})
