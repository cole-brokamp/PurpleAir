test_that("check_api_key works", {
  check_api_key() |>
    expect_message("Using valid")
})
