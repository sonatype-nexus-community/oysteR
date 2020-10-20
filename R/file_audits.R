# Cleans and converts field to vector
clean_field = function(field) {
  field = str_split(field, ",")[[1]]
  field = str_squish(field)
  pkgs = str_remove(field, " .*")
  pkgs
}

## Gets deps,
get_deps = function(pkgs) {
  dep = tools::package_dependencies(pkgs,
                                    which = c("Depends", "Imports", "LinkingTo"),
                                    recursive = TRUE)
  dep = unique(unlist(dep))
  dep
}

#' Audits Packages Listed in a DESCRIPTION file
#'
#' Looks for a DESCRIPTION file in \code{dir}, then extract
#' the packages in the fields & calculates the dependency tree.
#' @inheritParams audit_renv_lock
#' @param fields The DESCRIPTION field to parse. Default is Depends, Import, & Suggests.
#' @importFrom stringr str_split str_squish str_remove
#' @export
audit_description = function(dir = ".",
                             fields = c("Depends", "Imports", "Suggests"),
                             verbose = TRUE) {

  ## Read DESCRIPTION and extract fields
  des = read.dcf(file.path(dir, "DESCRIPTION"))
  out = des[, intersect(colnames(des), fields)]
  out = as.list(out)
  names(out) = NULL

  ## Clean fields and get deps
  pkgs = purrr::map(out, clean_field)
  all_dep = unlist(purrr::map(pkgs, get_deps))
  all_dep = sort(unique(all_dep))
  inst_pkgs = installed.packages()
  pkgs = inst_pkgs[rownames(inst_pkgs) %in% all_dep, "Version"]
  versions = as.vector(pkgs)
  pkgs = names(pkgs)
  audit(pkgs, versions, type = "CRAN", verbose = TRUE)
}

#' Audit an renv.lock File
#'
#' This function searches the OSS index for vulnerabilities recorded for packages listed in
#' an `renv.lock` file.
#' An `renv.lock` file is created by the `{renv}` package
#' which is used for project level package management in R.
#'
#' @param dir The file path of an renv.lock file.
#' @param verbose Default \code{TRUE}.
#'
#' @importFrom jsonlite read_json
#' @importFrom dplyr %>% mutate
#' @importFrom tibble as_tibble
#' @importFrom purrr map_chr pluck
#' @importFrom rlang .data
#' @export
#' @examples
#' \donttest{
#' # Looks for renv.lock file in dir
#' audit_renv_lock(dir = ".")
#' }
audit_renv_lock = function(dir = ".", verbose = TRUE) {
  renv_file = file.path(dir, "renv.lock")
  if (!file.exists(renv_file)) {
    cli::cli_alert_info("No renv.lock found")
    renv_pkgs = NULL
  } else {
    renv_lock = jsonlite::read_json(renv_file)
    renv_pkgs = purrr::map_chr(renv_lock$Packages, purrr::pluck, "Version")
  }
  audit(pkg = names(renv_pkgs), version = renv_pkgs, type = "cran", verbose = verbose)
}

#' Audit a requirements.txt File
#'
#' This function searches the OSS index for vulnerabilities recorded for packages listed
#' in a requirements.txt file based on PyPi.
#'
#' pip is a standard of python package management based on the Python Package Index (PyPI).
#' pip uses a requirements.txt file to manage of Python libraries.
#' The requirements.txt file contains package names and versions
#' (often used to manage a virtual environment).
#'
#' @param dir The file path of a requirements.txt file.
#' @inheritParams audit_renv_lock
#'
#' @importFrom dplyr %>% mutate
#' @importFrom purrr map_dfr
#' @importFrom tibble as_tibble
#' @export
audit_req_txt = function(dir = ".", verbose = TRUE) {
  req_file = file.path(dir, "requirements.txt")
  audit = readLines(req_file) %>%
    strsplit(">=|==|>") %>%
    map_dfr(~tibble::tibble(package = .x[1], version = .x[2])) %>%
    mutate(audit(pkg = .data$package, version = .data$version, type = "pypi", verbose = verbose))
  return(audit)
}



# TO DO: environment.yml for Conda
