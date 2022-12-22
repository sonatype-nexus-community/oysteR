test_that("Test audit_description", {
  skip_on_cran()

  repos = getOption("repos")
  on.exit(options(repos = repos))
  options(repos = c(CRAN = "https://cran.rstudio.com"))
  fname = system.file("extdata", "testthat", package = "oysteR", mustWork = TRUE)
  aud = audit_description(fname)
  expect_equal(nrow(aud), 6)
  expect_equal(sum(aud$no_of_vulnerabilities), 0)
})
