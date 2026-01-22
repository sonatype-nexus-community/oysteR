test_that("Check tokens", {
  l = list(username = "ABC", token = "ANC")
  expect_equal(get_token(l), l)
})

test_that("Check default OSS Index URL", {
  # Default URL should be returned when no custom URL is provided
  default_url = "https://ossindex.sonatype.org/api/v3/component-report"
  expect_equal(get_ossindex_url(), default_url)
})

test_that("Check custom OSS Index URL parameter", {
  # Custom URL passed as parameter should be returned
  custom_url = "https://custom.ossindex.org/api/v3/component-report"
  expect_equal(get_ossindex_url(custom_url), custom_url)
})

test_that("Check OSS Index URL from environment variable", {
  # Set environment variable
  custom_url = "https://env.ossindex.org/api/v3/component-report"
  withr::with_envvar(
    c(OSSINDEX_URL = custom_url),
    {
      expect_equal(get_ossindex_url(), custom_url)
    }
  )
})

test_that("Parameter takes precedence over environment variable", {
  # Parameter should override environment variable
  param_url = "https://param.ossindex.org/api/v3/component-report"
  env_url = "https://env.ossindex.org/api/v3/component-report"
  withr::with_envvar(
    c(OSSINDEX_URL = env_url),
    {
      expect_equal(get_ossindex_url(param_url), param_url)
    }
  )
})
