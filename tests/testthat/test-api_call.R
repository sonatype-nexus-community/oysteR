# # Generating the API data
# library(httptest)
# av = available.packages()
# av = tibble::as_tibble(av)[1:1280, c("Package", "Version")]
# colnames(av) = c("package", "version")
# saveRDS(av, file = "tests/testthat/dummy_packages.rds")
#
# httptest::start_capturing(path = "tests/testthat")
# oysteR::audit_deps(pkgs = av)
# httptest::stop_capturing()
httptest::with_mock_api({
  test_that("Calls to OSS Index work", {
    skip_on_cran()
    expect_true(file.exists("dummy_packages.rds"))
    pkgs = readRDS("dummy_packages.rds")
    r = audit(pkgs$package, pkgs$version, type = "cran")
    expect_equal(nrow(r), 1280)
    expect_equal(ncol(r), 8)
  })
})
