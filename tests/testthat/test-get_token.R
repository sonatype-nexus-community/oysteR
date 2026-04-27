test_that("get_token returns token as-is when already a list", {
  l = list(type = "bearer", token = "mytoken")
  expect_equal(get_token(l), l)
})

test_that("get_token returns bearer token when only OSSINDEX_TOKEN is set", {
  old_user  = Sys.getenv("OSSINDEX_USER")
  old_token = Sys.getenv("OSSINDEX_TOKEN")
  Sys.unsetenv("OSSINDEX_USER")
  Sys.setenv(OSSINDEX_TOKEN = "mytoken")

  t = get_token(NULL, verbose = FALSE)
  expect_equal(t$type, "bearer")
  expect_equal(t$token, "mytoken")

  if (nchar(old_user)  > 0) Sys.setenv(OSSINDEX_USER  = old_user)
  if (nchar(old_token) > 0) Sys.setenv(OSSINDEX_TOKEN = old_token) else Sys.unsetenv("OSSINDEX_TOKEN")
})

test_that("get_token returns bearer token when both OSSINDEX_USER and OSSINDEX_TOKEN are set", {
  old_user  = Sys.getenv("OSSINDEX_USER")
  old_token = Sys.getenv("OSSINDEX_TOKEN")
  Sys.setenv(OSSINDEX_USER = "user@example.com", OSSINDEX_TOKEN = "mytoken")

  t = get_token(NULL, verbose = FALSE)
  expect_equal(t$type, "bearer")
  expect_equal(t$token, "mytoken")

  if (nchar(old_user)  > 0) Sys.setenv(OSSINDEX_USER  = old_user) else Sys.unsetenv("OSSINDEX_USER")
  if (nchar(old_token) > 0) Sys.setenv(OSSINDEX_TOKEN = old_token) else Sys.unsetenv("OSSINDEX_TOKEN")
})

test_that("get_token returns NULL when no credentials are set", {
  old_user  = Sys.getenv("OSSINDEX_USER")
  old_token = Sys.getenv("OSSINDEX_TOKEN")
  Sys.unsetenv("OSSINDEX_USER")
  Sys.unsetenv("OSSINDEX_TOKEN")

  expect_null(get_token(NULL, verbose = FALSE))

  if (nchar(old_user)  > 0) Sys.setenv(OSSINDEX_USER  = old_user)
  if (nchar(old_token) > 0) Sys.setenv(OSSINDEX_TOKEN = old_token)
})
