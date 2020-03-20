test_that("Test Purls", {
  skip_on_cran()

  # Test edge case
  pkgs = data.frame(Package = character(0), Version = character(0))
  deps = audit_deps(pkgs)
  expect_equal(nrow(deps), 0)
  expect_equal(ncol(deps), 5)

  # Pass package
  pkgs = data.frame(Package = c("abind", "acepack"),
                         Version = c("1.4-5", "1.4.1"))
  deps = expect_message(audit_deps(pkgs))
  expect_equal(nrow(deps), 2)
  expect_equal(ncol(deps), 5)

})
