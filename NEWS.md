# oysteR 0.1.0 _2020-12-31_ 
  * Feature: Add API caching. Calls are now cached for 12 hours (on R4+ only)
  * Feature: Extract packages from `requirements.txt`, `renv.lock`, and `environment.yml` files
    * Adds `audit_req_txt()`, `audit_renv_lock()`, and `audit_env_yml()` functions 
  * Feature: Handle more general vulnerabilities
  * Feature: Add `audit_description()` function
  * Feature: Add `expect_secure()` for the {testthat} package
  * Feature: Use `~/.ossindex/.oss-index-config`, if it exists
  * Feature: Add a pkgdown website. Thanks to @josiahParry for the nice CSS.
  * Add Josiah Parry as an author
  * Minor: Link to [jumpingrivers.com](https://www.jumpingrivers.com) blog post
  * Minor: Make `verbose = FALSE` completely silent

# oysteR 0.0.3
  * CRAN release
  * Use `donttest{}` in examples
  * Fix "spelling" mistakes in `DESCRIPTION`

# oysteR 0.0.1
  * Initial version
