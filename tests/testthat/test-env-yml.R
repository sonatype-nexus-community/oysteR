test_that("Test environment.yml file", {
  skip_on_cran()

  # Sanity check to make sure the directory exists
  expect_true(file.exists("environment.yml"))
  audit = oysteR::audit_conda()
  expect_equal(ncol(audit), 8)
  expect_equal(nrow(audit), 73)
  expect_gte(sum(audit$no_of_vulnerabilities), 95) # This could increase

  # ## Run when no file available
  expect_error(oysteR::audit_conda(fname = "file-does-not-exist"))
})
