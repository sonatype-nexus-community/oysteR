test_that("Test audit_deps", {
  skip_on_cran()

  # Test edge case
  pkgs = data.frame(package = character(0), version = character(0))
  deps = audit_deps(pkgs)
  expect_equal(nrow(deps), 0)
  expect_equal(ncol(deps), 7)

  # Pass package
  pkgs = data.frame(package = c("abind", "acepack"),
                         version = c("1.4-5", "1.4.1"))
  deps = expect_message(audit_deps(pkgs))
  expect_equal(nrow(deps), 2)
  expect_equal(ncol(deps), 7)

})
