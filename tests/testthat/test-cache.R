test_that("Test cache", {
  skip_on_cran()
  ## Test remove cache
  if (as.numeric(R.version$major) > 3) {
    cache_file = get_cache_file()

    expect_true(file.exists(cache_file))

    ## Cache the "cache", otherwise tests will become annoyingly slow
    file.copy(cache_file, to = paste0(cache_file, "-testthat"))
    expect_null(remove_cache())
    expect_true(!file.exists(cache_file))
    expect_null(remove_cache()) # Test when no file exists

    ## Reinstate the cache file
    file.copy(from = paste0(cache_file, "-testthat"), cache_file)

  }

}
)
