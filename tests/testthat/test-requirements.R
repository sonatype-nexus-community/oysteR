test_that("Test requirements file", {
  skip_on_cran()

  # Sanity check to make sure the directory exists
  expect_true(file.exists("requirements.txt"))
  audit = audit_req_txt()
  expect_equal(ncol(audit), 8)
  expect_equal(nrow(audit), 31)
})
