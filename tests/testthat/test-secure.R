test_that("Test expect_secure", {
  skip_on_cran()
  skip_if_no_token()
  ## stats only depends on base packages, so it shouldn't pick up new CVEs
  oysteR::expect_secure("stats")
})
