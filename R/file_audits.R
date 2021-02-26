check_file_exists = function(dir, fname) {
  fpath = file.path(dir, fname)
  if (!file.exists(fpath)) {
    stop(fpath, " not found", call. = FALSE)
  }
  return(fpath)
}

# Cleans and converts field to vector
clean_description_field = function(field) {
  field = stringr::str_split(field, ",")[[1]]
  field = stringr::str_squish(field)
  pkgs = stringr::str_remove(field, " .*")
  pkgs
}

## Gets deps,
get_pkg_deps = function(pkgs) {
  dep = tools::package_dependencies(pkgs,
                                    which = c("Depends", "Imports", "LinkingTo"),
                                    recursive = TRUE)
  dep = unlist(dep)
  unique(c(pkgs, dep))
}

#' Audits Packages Listed in a DESCRIPTION file
#'
#' Looks for a DESCRIPTION file in `dir`, then extract
#' the packages in the fields & calculates the dependency tree.
#' @inheritParams audit_renv_lock
#' @param fields The DESCRIPTION field to parse. Default is Depends, Import, & Suggests.
#' @importFrom stringr str_split str_squish str_remove
#' @export
#' @examples
#' \dontrun{
#' # Looks for a DESCRIPTION file in dir
#' audit_description(dir = ".")
#' }
audit_description = function(dir = ".",
                             fields = c("Depends", "Imports", "Suggests"),
                             verbose = TRUE) {

  ## Read DESCRIPTION and extract fields
  fname = check_file_exists(dir, "DESCRIPTION")
  des = read.dcf(fname)
  out = des[, intersect(colnames(des), fields)]
  out = as.list(out)
  names(out) = NULL

  ## Clean fields and get deps
  pkgs = purrr::map(out, clean_description_field)
  all_dep = unlist(purrr::map(pkgs, get_pkg_deps))
  all_dep = sort(unique(all_dep))
  inst_pkgs = installed.packages()
  pkgs = inst_pkgs[rownames(inst_pkgs) %in% all_dep, "Version"]
  versions = as.vector(pkgs)
  pkgs = names(pkgs)
  audit(pkgs, versions, type = "CRAN", verbose = verbose)
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
#' \dontrun{
#' # Looks for renv.lock file in dir
#' audit_renv_lock(dir = ".")
#' }
audit_renv_lock = function(dir = ".", verbose = TRUE) {
  fname = check_file_exists(dir, "renv.lock")
  renv_lock = jsonlite::read_json(fname)
  renv_pkgs = purrr::map_chr(renv_lock$Packages, purrr::pluck, "Version")
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
#' @examples
#' \dontrun{
#' # Looks for a requirements.txt file in dir
#' audit_description(dir = ".")
#' }
audit_req_txt = function(dir = ".", verbose = TRUE) {
  fname = check_file_exists(dir, "requirements.txt")
  audit = readLines(fname) %>%
    strsplit(">=|==|>") %>%
    map_dfr(~tibble::tibble(package = .x[1], version = .x[2])) %>%
    mutate(audit(pkg = .data$package, version = .data$version, type = "pypi", verbose = verbose))
  return(audit)
}

#' Audit a conda environment file
#'
#' This function searches the OSS index for vulnerabilities recorded for packages listed
#' in a Conda environment file typically called environment.yml but are subject to varied names.
#' Conda environment can contain packages from both Conda and PyPI. All packages will be audited.
#'
#' @param dir The directory containing a conda environment yaml file.
#' @param fname The file name of conda environment yaml file.
#' @param verbose Default \code{TRUE}.
#'
#' @importFrom purrr keep map map_dfr pluck discard
#' @importFrom dplyr mutate bind_rows
#' @importFrom magrittr %>%
#' @importFrom tibble tibble
#' @importFrom yaml read_yaml
#' @export
#' @examples \dontrun{
#' # Looks for a requirements.txt file in dir
#' audit_env_yml(dir = ".")
#' }
audit_env_yml = function(dir = ".", fname = "environment.yml", verbose = TRUE) {

  # check if file exists if it does create file path
  # allow for fname because conda envs are not always title `environment.yml`
  env_fname = check_file_exists(dir, fname)

  # read in the yaml
  env_yml = yaml::read_yaml(env_fname)

  # parse all dependencies
  env_deps = env_yml[["dependencies"]]

  # conda dependencies
  conda_deps_raw = unlist(purrr::keep(env_deps, is.character))

  conda_deps = strsplit(conda_deps_raw, ">=|==|>|=") %>%
    map_dfr(~tibble::tibble(package = .x[1], version = .x[2])) %>%
    mutate(type = "conda")

  # pip dependencies
  pip_deps_raw = purrr::map(env_deps, purrr::pluck, "pip") %>%
    unlist(purrr::discard(., is.null))

  # if there are no pip packages create empty tibble
  if (is.null(pip_deps_raw)) {
    pip_deps = tibble::tibble(package = character(0),
                               version = character(0),
                               type = character(0))
  } else {
    pip_deps = strsplit(pip_deps_raw, ">=|==|>") %>%
      purrr::map_dfr(~tibble::tibble(package = .x[1], version = .x[2])) %>%
      dplyr::mutate(type = "pip")
  }


  all_deps = dplyr::bind_rows(conda_deps, pip_deps)

  aud = audit(all_deps$package, all_deps$version, all_deps$type, verbose = verbose)

  return(aud)
}




