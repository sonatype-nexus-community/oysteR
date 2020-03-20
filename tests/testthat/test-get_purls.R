test_that("Test Purls", {
  skip_on_cran()

  # Test edge case
  pkgs = data.frame(package = character(0), version = character(0))
  expect_equal(length(get_purls(pkgs)), 0)

  pkgs = data.frame(package = c("abind", "acepack"),
                    version = c("1.4-5", "1.4.1"))
  purls = get_purls(pkgs)
  expect_equal(2, length(purls))

  # So this package has at least 9 dependencies
  # So this is a sanity check that installed.packages()
  # is doing something sensible
  pkgs = get_pkgs()
  expect_gt(nrow(pkgs), 9)
})
