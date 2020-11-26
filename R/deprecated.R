#' Check Package Dependencies
#'
#' Collects R dependencies and checks them against OSS Index.
#' Returns a tibble of results.
#'
#' This function is deprecated. See
#' @details By default, packages listed in \code{installed.packages()} are scanned by sonatype.
#' However, you can pass your own data frame of packages. This data frame should have two columns,
#' \code{version} and \code{package}.
#' @param pkgs Default \code{NULL}. See details for further information.
#' @param verbose Default \code{TRUE}.
#' @return A tibble/data.frame.
#' @export
audit_deps = function(pkgs = NULL, verbose = TRUE) {  # nocov start
  .Deprecated("audit_installed_r_pkgs or just audit")
  if (is.null(pkgs))
    audit_installed_r_pkgs(verbose = verbose)
  else
    audit(pkgs$package, version = pkgs$version, type = "cran", verbose = verbose)
}
# nocov end
