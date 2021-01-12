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

#' Search for Package Vulnerabilities
#'
#' Search the OSS Index for known package vulnerabilities in any of the supported ecosystems—
#' e.g. CRAN, PyPI, Conda, NPM, Maven, etc.
#' see https://ossindex.sonatype.org/ecosystems for full list.
#'
#' @param pkg A vector of package names to search in the OSS Index.
#' @param version The specific package version to search for.
#' By default it will search all known versions. If not `*`, must be the same length as pkg.
#' @param type The package management environment. For R packages, set equal to "cran".
#' This defaults to \code{"cran"}. See https://ossindex.sonatype.org/ecosystems.
#' @param verbose Default \code{TRUE}.
#'
#' @export
#' @examples
#' \donttest{
#' pkg = c("abind", "acepack")
#' version = c("1.4-5", "1.4.1")
#' audit(pkg, version, type = "cran")
#' }
audit = function(pkg, version, type, verbose = TRUE) {

  if (is.null(pkg)) pkg = character(0)
  if (is.null(version)) version = character(0)
  # Create the purls. Checks will be inherited
  purls = generate_purls(pkg, version, type)
  ## Get cache & remove cached purls
  cache = get_cache()
  cache = cache[cache$oss_package %in% unlist(purls), ]
  is_cached = unlist(purls) %in% cache$oss_package

  if (as.numeric(R.version$major) > 3 && isTRUE(verbose)) {
    cli::cli_alert_info("Using cached results for {sum(is_cached)} package{?s}")
  }

  purls = purls[!is_cached]
  pkgs = tibble::tibble(package = pkg, version = version, type = type)[!is_cached, ]

  ## Call OSS index on remaining
  results = call_oss_index(purls, verbose = verbose)
  audit = dplyr::bind_cols(pkgs, results)

  # Update cache and combine
  update_cache(audit)

  audit = dplyr::bind_rows(audit, cache)
  if (isTRUE(verbose)) {
    audit_verbose(audit)
  }
  return(audit)
}

#' Audit Installed Packages
#'
#' Audits all installed packages by calling \code{installed.packages()}
#' and checking them against the OSS Index.
#' @param verbose Default \code{TRUE}.
#' @return A tibble/data.frame.
#' @importFrom utils installed.packages
#' @export
#' @examples
#' \dontrun{
#' # Audit installed packages
#' # This calls installed.packages()
#' pkgs = audit_installed_r_pkgs()
#' }
audit_installed_r_pkgs = function(verbose = TRUE) {
  pkgs = get_r_pkgs(verbose = verbose)
  audit(pkg = pkgs$package, version = pkgs$version, type = "cran", verbose = verbose)
}
