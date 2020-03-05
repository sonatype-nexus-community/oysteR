library(testthat)
library(httptest)
testthat::context("OSS Index requests")

library(oysteR)

httptest::with_mock_api({
  test_that("Calls to OSS Index work", {
    r <- oysteR::call_oss_index(c("pkg:cran/thing@1.0.0", "pkg:cran/thing@2.0.0", "pkg:cran/thing@3.0.0"))
    expect_equal(length(r), 99)
  })
})
