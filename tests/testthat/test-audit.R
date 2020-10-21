test_that("Test audit_deps", {
  skip_on_cran()

  # Test edge cases
  deps = audit(pkg = character(0), version = character(0), type = "cran")
  expect_equal(nrow(deps), 0)
  expect_equal(ncol(deps), 8)
  deps = audit(pkg = NULL, version = NULL, type = "cran")
  expect_equal(nrow(deps), 0)
  expect_equal(ncol(deps), 8)

  # Pass package
  deps = expect_message(audit(pkg = c("abind", "acepack"),
                              version = c("1.4-5", "1.4.1"), type = "cran"))
  expect_equal(nrow(deps), 2)
  expect_equal(ncol(deps), 8)

  # Basic checks on argument passing
  expect_error(audit(pkg = c("abind", "acepack"), version = "1.4-5", type = "cran"))
  expect_error(audit(pkg = "abind", version = "1.4-5", type = c("cran", "python")))
})

