#' Audit an renv.lock file.
#'
#' This function searches the OSS index for vulnerabilities recorded for packages listed in
#' an `renv.lock` file.
#'
#' An `renv.lock` file is created by the `{renv}` package (https://rstudio.github.io/renv/)
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
audit_renv_lock = function(dir = ".", verbose = TRUE) {
  renv_file = file.path(dir, "renv.lock")
  renv_lock = jsonlite::read_json(renv_file)
  renv_pkgs = purrr::map_chr(renv_lock$Packages, purrr::pluck, "Version")
  pkgs = tibble::tibble(package = names(renv_pkgs), version = renv_pkgs)
  audit_deps(pkgs, verbose = verbose)
}

#' Audit a requirements.txt file.
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
    mutate(audit_pkgs(.data$package, .data$version, type = "pypi", verbose = verbose))
  return(audit)
}


# TO DO: environment.yml for Conda
