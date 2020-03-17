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
# httptest::with_mock_api({
#   test_that("Calls to OSS Index work", {
#     r <- oysteR::call_oss_index(c("pkg:cran/thing@1.0.0",
#     "pkg:cran/thing@2.0.0", "pkg:cran/thing@3.0.0"))
#     expect_equal(length(r), 99)
#   })
# })
