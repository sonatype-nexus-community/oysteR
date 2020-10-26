test_that("Test audit_deps", {
  skip_on_cran()

  # Known vulnerabilitiy
  aud = audit("widgetframe", "0.3.1", type = "cran")
  vul = get_vulnerabilities(aud)
  expect_true(ncol(vul) == 14)
  expect_true(nrow(vul) == 1)
  # Pass empty
  empty = get_vulnerabilities(aud[-1, ])
  expect_true(nrow(empty) == 0)
  ## Check for matching columns
  cols_match = unlist(vapply(1:13,
         function(i) colnames(vul)[i] %in% colnames(empty)[i],
         FUN.VALUE = logical(1)))
  expect_true(all(cols_match))
})
