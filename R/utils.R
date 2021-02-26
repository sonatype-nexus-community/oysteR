#' Function to generate purls
#'
#' Generates purls from a vector of package names, version, and type. `version`
#' must be the same length as `pkg`.
#' `type` must of the same length or else be of length one.
#'
#' @keywords internal
generate_purls = function(pkg, version, type) {
  # Add in safety net
  if ((is.null(pkg) && is.null(version)) ||
      (length(pkg) == 0L && length(version) == 0L)) return(list())
  # Institute checks for both version and type.
  # type and version must be the same length as pkg or
  # of length 1.
  if (length(pkg) != length(version)) {
    stop("pkgs must be the same length as version.", call. = FALSE)
  }
  if ((length(type) != 1L) && (length(pkg) != length(type))) {
    stop("type must be 1 or the same length as pkgs", call. =  FALSE)
  }
  # Make lower case to make caching better
  type = tolower(type)
  version = as.character(version)
  # List format required for httr call
  # The list translates to the body of the curl call
  # Each purl must be it's own list element hence the use of as.list over list
  # must have version for Sonatype
  no_missing_versions = sum(is.na(version) | nchar(version) == 0L)
  # create alert if missing versions
  if (no_missing_versions > 0) {
    cli::cli_h3("Missing pkg versions")
    missing_pkgs = paste(pkg[is.na(version) | nchar(version) == 0L], collapse = ', ')
    cli::cli_alert_warning("{no_missing_versions} package{?s} with missing versions: \\
                           {missing_pkgs}")

    cli::cli_alert_warning("oysteR will check all package versions.")
    cli::cli_alert_warning("This may result in false positives.")
    cli::cat_line()

    version[is.na(version) | nchar(version) == 0L] = "*"
  }
  # generate purls
  purls = as.list(paste0("pkg:", type, "/", pkg, "@", version))

  # return purls
  return(purls)
}

#' Get data frame of installed packages
#'
#' @importFrom tibble as_tibble tibble
#' @keywords internal
get_r_pkgs = function(verbose = TRUE) {
  if (isTRUE(verbose)) {
    cli::cli_alert_info("Calling {.pkg installed.packages()}, this may take time")
  }
  pkgs = tibble::as_tibble(installed.packages()[, c(1, 3)])
  # XXX: Remove line when audit_dep is removed
  colnames(pkgs) = c("package", "version")
  return(pkgs)
}
