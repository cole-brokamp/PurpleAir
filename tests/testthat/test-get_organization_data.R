test_that("get_organization_data works", {
  od <- get_organization_data()
  expect_equal(od$organization_name, "Organization Cole Brokamp C8A17F7C")
})
