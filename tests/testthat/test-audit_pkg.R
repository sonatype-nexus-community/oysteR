test_that("Test audit_description", {
  skip_on_cran()

  ## Checking function and also checking _this_ package
  ## Gets the DESCRIPTION from where the pkg is installed
  options(repos = c(CRAN = "https://cran.rstudio.com"))
  pkg_loc = system.file(package = "oysteR")
  aud = audit_description(pkg_loc)
  expect_true(nrow(aud) > 30)
  expect_equal(sum(aud$no_of_vulnerabilities), 0)
})
