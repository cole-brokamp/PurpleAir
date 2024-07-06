test_that("check_api_key works", {
  skip_on_cran()
  check_api_key() |>
    expect_message("Using valid")
})
