test_that("Test Renvlock file", {
  skip_on_cran()

  dir = system.file("extdata", "testthat", package = "oysteR", mustWork = TRUE)
  audit = oysteR::audit_renv_lock(dir = dir)
  expect_equal(ncol(audit), 8)
  expect_equal(nrow(audit), 57)
  ## Run when no renv lock available
  expect_error(oysteR::audit_renv_lock("../"))
})
