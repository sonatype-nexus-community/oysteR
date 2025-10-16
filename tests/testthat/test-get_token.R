test_that("Check tokens", {
  l = list(username = "ABC", token = "ANC")
  expect_equal(get_token(l), l)
})
