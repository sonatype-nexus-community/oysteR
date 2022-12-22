test_that("Test environment.yml file", {
  skip_on_cran()

  # Sanity check to make sure the directory exists
  dir = system.file("extdata", "testthat", package = "oysteR", mustWork = TRUE)
  audit = audit_conda(dir = dir)
  expect_equal(ncol(audit), 8)
  expect_equal(nrow(audit), 73)
  expect_gte(sum(audit$no_of_vulnerabilities), 95) # This could increase

  # ## Run when no file available
  expect_error(audit_conda(fname = "file-does-not-exist"))
})
