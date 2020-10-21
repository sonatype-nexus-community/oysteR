test_that("Test audit_description", {
  skip_on_cran()

  repos = getOption("repos")
  on.exit(options(repos = repos))
  options(repos = c(CRAN = "https://cran.rstudio.com"))
  aud = audit_description(".")
  expect_equal(nrow(aud), 3)
  expect_equal(sum(aud$no_of_vulnerabilities), 0)
})
