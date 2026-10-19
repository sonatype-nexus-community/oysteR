test_that("Test installed packages", {
  skip_on_cran()
  skip_if_no_token()
  aud = audit_installed_r_pkgs()
  expect_true(nrow(aud) > 50)
  expect_equal(ncol(aud), 8)
})
