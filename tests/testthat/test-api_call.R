httptest::with_mock_api({
  test_that("Calls to OSS Index work", {
    r <- oysteR::call_oss_index(c("pkg:cran/thing@1.0.0",
    "pkg:cran/thing@2.0.0", "pkg:cran/thing@3.0.0"), verbose = TRUE)

    # This should be 99, but currently shows 95? Need to figure out why
    expect_equal(nrow(r), 99)
  })
})
