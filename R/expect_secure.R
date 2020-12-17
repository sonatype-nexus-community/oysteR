#' Vulnerability Detection via Testthat
#'
#' A \code{testthat} version for detecting vulnerabilities.
#' This function is used within the \code{testthat} framework.
#' As testthat strips out the repositories from options,
#' we have to set the value locally in the function, i.e. the
#' value you have in \code{getOption("repos")} is not used.
#'
#' @details An important proviso is that we are only testing packages for specific versions.
#' By default, this will be the latest version on CRAN.
#' This may differ for users or if you are using a CRAN snapshot.
#' For the latter, simply change the `repo` parameter.
#' @param pkg The pkg to check
#' @param repo The CRAN repository, used to get version numbers
#' @inheritParams audit_renv_lock
#' @export
#' @examples
#' \donttest{
#'  # Typically used inside testthat
#'  oysteR::expect_secure("oysteR")
#' }
expect_secure = function(pkg,
                         repo = "https://cran.rstudio.com",
                         verbose = FALSE) {
  ## Need to set the repo, as testthat seems to strip this out?
  repos = getOption("repos")
  on.exit(options(repos = repos))
  options(repos = c(CRAN = repo))

  ## Look up vulnerabilities
  pkg_loc = system.file(package = pkg)
  aud = audit_description(pkg_loc, verbose = verbose)
  no_of_vul = sum(aud$no_of_vulnerabilities)

  ## Report results
  bad_pkgs = aud[aud$no_of_vulnerabilities > 0, ]$package
  testthat::expect(
    no_of_vul == 0,
    sprintf("%s has %i vulnerabilities: %s",
            pkg, no_of_vul, paste0(bad_pkgs, collapse = ", "))
  )

  return(invisible(aud))
}
