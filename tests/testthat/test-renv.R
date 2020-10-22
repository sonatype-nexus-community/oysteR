test_that("Test Renvlock file", {
  skip_on_cran()

  # Sanity check to make sure the directory exists
  expect_true(file.exists("renv.lock"))
  audit = oysteR::audit_renv_lock()
  expect_equal(ncol(audit), 8)
  expect_equal(nrow(audit), 57)
  ## Run when no renv lock available
  expect_error(oysteR::audit_renv_lock("../"))
})
