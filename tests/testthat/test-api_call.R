# Generating the API data
# av = available.packages()
# av = tibble::as_tibble(av)[1:1280, c("Package", "Version")]
# saveRDS(av, file = "tests/testthat/dummy_packages.rds")
#
# httptest::start_capturing(path = "tests/testthat")
# oysteR::audit_deps(pkgs = av)
# httptest::stop_capturing()

httptest::with_mock_api({
  test_that("Calls to OSS Index work", {

    pkgs = readRDS("dummy_packages.rds")
    r = audit_deps(pkgs)

    expect_equal(nrow(r), 1280)
  })
})
