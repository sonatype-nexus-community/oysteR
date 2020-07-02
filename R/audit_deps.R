# Copyright 2020 Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License."

#' @importFrom tibble as_tibble tibble
get_pkgs = function(pkgs = NULL) {
  if (is.null(pkgs)) {
    cli::cli_alert_info("Calling {.pkg installed.packages()}, this may take time")
    pkgs = tibble::as_tibble(installed.packages()[, c(1, 3:4)])
    pkgs = pkgs[is.na(pkgs$Priority), c("Package", "Version")]
    colnames(pkgs) = c("package", "version")
  }
  return(pkgs)
}

# Scans R packages and creates a list of purls.
# List format required for httr call

#' @importFrom utils installed.packages
get_purls = function(pkgs) {

  # Extract Package and Version columns
  purls = c()
  if (nrow(pkgs) > 0) {
    purls = paste0("pkg:cran/", pkgs$package, "@", pkgs$version)
  }
  purls = as.list(purls)
  return(purls)
}

#' @title Check Package Dependencies
#'
#' Collects R dependencies and checks them against OSS Index.
#' Returns a tibble of results.
#'
#' @details By default, packages listed in \code{installed.packages()} are scanned by sonatype.
#' However, you can pass your own data frame of packages. This data frame should have two columns,
#' \code{version} and \code{package}.
#' @param pkgs Default \code{NULL}. See details for further information.
#' @param verbose Default \code{TRUE}.
#' @return A tibble/data.frame.
#' @export
#' @examples
#' \donttest{
#' # Audit installed packages
#' # This calls installed.packages()
#' # pkgs = audit_deps()
#'
#' # Or pass your own packages
#' pkgs = data.frame(package = c("abind", "acepack"),
#'                   version = c("1.4-5", "1.4.1"))
#' audit_deps(pkgs)
#' }
audit_deps = function(pkgs = NULL, verbose = TRUE) {
  pkgs = get_pkgs(pkgs = pkgs)
  purls = get_purls(pkgs = pkgs)
  results = call_oss_index(purls, verbose = verbose)

  if (isTRUE(verbose)) {
    audit_deps_verbose(results)
  }
  results = dplyr::bind_cols(pkgs, results)
  return(results)
}

#' @title Extract vulnerabilities
#'
#' Parse the audit data frame (obtained via \code{audit_deps}), and extract
#' the vulnerabilities.
#' @param audit Output from \code{audit_deps}.
#' @importFrom purrr map_dfr map
#' @importFrom tidyr unnest
#' @export
#' @examples
#' \donttest{
#' # Audit installed packages
#' # This calls installed.packages()
#' # pkgs = audit_deps()
#'
#' # Or pass your own packages
#' pkgs = data.frame(package = c("abind", "acepack"),
#'                   version = c("1.4-5", "1.4.1"))
#' deps = audit_deps(pkgs)
#' get_vulnerabilities(deps)
#' }
get_vulnerabilities = function(audit) {
  if (sum(audit$no_of_vulnerabilities) == 0) {
    return(tibble(cvss_id = character(0), cvss_title = character(0),
                  cvss_description = character(0), cvss_score = character(0),
                  cvss_vector = character(0), cvss_cwe = character(0),
                  cvss_reference = character(0)))
  }

  audit$vulnerabilities = audit$vulnerabilities %>%
    map(~ map_dfr(.x, ~tibble(cvss_id = .x[[1]],
                              cvss_title = .x[[2]],
                              cvss_description = .x[[3]],
                              cvss_score = .x[[4]],
                              cvss_vector = .x[[5]],
                              cvss_cwe = .x[[6]],
                              cvss_reference = .x[[7]])))
  tidyr::unnest(audit, vulnerabilities)
}
