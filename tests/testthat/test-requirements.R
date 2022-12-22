test_that("Test requirements file", {
  skip_on_cran()

  dir = system.file("extdata", "testthat", package = "oysteR", mustWork = TRUE)
  audit = audit_req_txt(dir)
  expect_equal(ncol(audit), 8)
  expect_equal(nrow(audit), 31)
})
