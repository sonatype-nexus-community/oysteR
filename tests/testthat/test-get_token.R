test_that("Check tokens", {
  l = list(username = "ABC", token = "ANC")
  expect_equal(get_token(l), l)
})

test_that("Empty or missing credentials give NULL", {
  expect_null(make_token("", ""))
  expect_null(make_token("ABC", ""))
  expect_null(make_token(NULL, "ANC"))
  expect_null(make_token(NA_character_, "ANC"))
  expect_equal(make_token("ABC", "ANC"), list(user = "ABC", token = "ANC"))
})

test_that("Environment variables are used when set", {
  old = Sys.getenv(c("OSSINDEX_USER", "OSSINDEX_TOKEN"), unset = NA)
  on.exit({
    for (nm in names(old)) {
      if (is.na(old[[nm]])) Sys.unsetenv(nm) else do.call(Sys.setenv, as.list(old[nm]))
    }
  })

  Sys.setenv(OSSINDEX_USER = "ABC", OSSINDEX_TOKEN = "ANC")
  expect_equal(get_env_token(), list(user = "ABC", token = "ANC"))

  Sys.setenv(OSSINDEX_USER = "", OSSINDEX_TOKEN = "")
  expect_null(get_env_token())
})

test_that("Config file is read, and incomplete files are ignored", {
  expect_null(get_config_token(tempfile()))

  path = tempfile()
  writeLines(c("ossi:", "  Username: ABC", "  Token: ANC"), path)
  expect_equal(get_config_token(path), list(user = "ABC", token = "ANC"))

  writeLines(c("ossi:", "  Username: ABC"), path)
  expect_null(get_config_token(path))
})

test_that("A clear error is given when no credentials are found", {
  local_mocked_bindings(get_token = function(...) NULL)
  expect_error(call_oss_index("pkg:cran/abind@1.4-5", FALSE, NULL), "requires credentials")
})
