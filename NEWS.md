# oysteR 0.1.3.9001 _2021-05-18_ 
  * Bug: Incorrectly states how many packages were found in the database (see #62)

# oysteR 0.1.3 _2021-03-11-_ 
  * Internal: Return missing values as `NA`'s (see #59)

# oysteR 0.1.2 _2021-02-26_ 
  * Feature: Add `audit_conda()` functions 
  * Feature: Add Josiah Parry as an author
  * Feature: Handle missing versions in a nice way

# oysteR 0.1.1 _2021-01-08_
  * Use `dontrun{}` in examples that may hit rate limits.

# oysteR 0.1.0 _2020-12-17_ 
  * Feature: Add API caching. Calls are now cached for 12 hours (on R4+ only)
  * Feature: Extract packages from `requirements.txt`, `renv.lock`, and `environment.yml` files
  * Feature: Handle more general vulnerabilities
  * Feature: Add `audit_description()` function
  * Feature: Add `expect_secure()` for the {testthat} package
  * Feature: Use `~/.ossindex/.oss-index-config`, if it exists
  * Feature: Add a pkgdown website. Thanks to @josiahParry for the nice CSS.
  * Add Josiah Parry as an contributor
  * Minor: Link to [jumpingrivers.com](https://www.jumpingrivers.com) blog post
  * Minor: Make `verbose = FALSE` completely silent

# oysteR 0.0.3
  * CRAN release
  * Use `donttest{}` in examples
  * Fix "spelling" mistakes in `DESCRIPTION`

# oysteR 0.0.1
  * Initial version
