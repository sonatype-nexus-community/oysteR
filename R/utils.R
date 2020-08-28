#' Function to generate purls
#'
#' Generates purls from a vector of package names, version, and type. `version` and `type`
#' must be the same length as `pkg` or else be of length one.
#'
#' @keywords internal
gen_purls = function(pkg, version = "*", type = "cran") {

  # Institute checks for both version and type.
  # type and version must be the same length as pkg or
  # of length 1.
  if ((length(type) > length(pkg)) && (length(type) != 1L)) {
    stop("`type` must be length 1 or same length as `pkg`.", call. = FALSE)
  }
  if ((length(version) > length(pkg)) && (length(version) != 1L)) {
    stop("`version` must be length 1 or same length as `pkg`.", call. =  FALSE)
  }
  # List format required for httr call
  # The list translates to the body of the curl call
  # Each purl must be it's own list element hence the use of as.list over list
  purls = as.list(paste0("pkg:", type, "/", pkg, "@", version))
  return(purls)
}

#' Get data frame of installed packages
#'
#' @importFrom tibble as_tibble tibble
#' @keywords internal
get_pkgs = function(pkgs = NULL) {
  if (is.null(pkgs)) {
    cli::cli_alert_info("Calling {.pkg installed.packages()}, this may take time")
    pkgs = tibble::as_tibble(installed.packages()[, c(1, 3:4)])

    # ensuring all packages are included including base and recommended
    pkgs = pkgs[, c("Package", "Version")]
    colnames(pkgs) = c("package", "version")
  }
  return(pkgs)
}

#' Create a list of purls based on installed packages
#'
#' @importFrom utils installed.packages
#' @keywords internal
get_purls = function(pkgs) {
  if (nrow(pkgs) == 0) return(list())

  # Extract Package and Version columns
  purls = gen_purls(pkg = pkgs$package, version = pkgs$version, type = "cran")
  return(purls)
}
