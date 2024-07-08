test_that("check_api_key works", {
  skip_on_cran()
  testthat::skip_if(Sys.getenv("PURPLE_AIR_API_KEY") == "", "no PurpleAir API key present")
  testthat::skip_if_offline()
  check_api_key() |>
    expect_message("Using valid")
})
