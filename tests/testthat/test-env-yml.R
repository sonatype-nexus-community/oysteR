test_that("Test environment.yml file", {
  skip_on_cran()

  # Sanity check to make sure the directory exists
  expect_true(file.exists("environment.yml"))
  audit = oysteR::audit_env_yml()
  expect_equal(ncol(audit), 8)
  expect_equal(nrow(audit), 73)
  # ## Run when no renv lock available
  expect_error(oysteR::audit_env_yml("../"))
})
