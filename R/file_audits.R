#' Audit an renv.lock file.
#'
#' This function searches the OSS index for vulnerabilities recorded for packages listed in an renv.lock file.
#'
#' An renv.lock file is created by the renv package (https://rstudio.github.io/renv/) which is used for project level package management in R.
#'
#' @param lockfile The file path of an renv.lock file.
#' @param verbose Default \code{TRUE}.
#'
#' @importFrom jsonlite read_json
#' @importFrom dplyr %>% mutate
#' @importFrom tibble as_tibble
#' @importFrom purrr map_chr pluck
#' @export
audit_renv_lock <- function(lockfile, verbose = TRUE) {

  renv_lock <- jsonlite::read_json("renv.lock")

  renv_pkgs <- map_chr(renv_lock$Packages, pluck, "Version")

  data.frame(package = names(renv_pkgs),
             version = renv_pkgs,
             row.names = NULL) %>%
    mutate(audit_pkgs(package, version, verbose = verbose)) %>%
    as_tibble()

}

#' Audit a requirements.txt file.
#'
#' This function searches the OSS index for vulnerabilities recorded for packages listed in a requirements.txt file based on PyPi.
#'
#' pip is a standard of python package management based on the Python Package Index (PyPI). pip uses a requirements.txt file to manage of Python libraries. The requirements.txt file contains package names and versions (often used to manage a virtual environment).
#'
#' @param requirements The file path of a requirements.txt file.
#' @param verbose Default \code{TRUE}.
#'
#' @importFrom dplyr %>% mutate
#' @importFrom purrr map_dfr
#' @importFrom tibble as_tibble
#' @export

audit_req_txt <- function(requirements, verbose = TRUE) {

  readLines(requirements) %>%
    strsplit(">=|==|>") %>%
    map_dfr(~data.frame(package = .x[1], version = .x[2])) %>%
    mutate(audit_pkgs(package, version, schema = "pypi", verbose = verbose)) %>%
    as_tibble()

}


# TO DO: environment.yml for Conda
