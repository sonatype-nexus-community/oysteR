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

#' Check Package Dependencies
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
  dplyr::bind_cols(pkgs, results)

}

#' Search for package vulnerabilities
#'
#' Search the OSS Index for known package vulnerabilities in any of the supported ecosystems—
#' e.g. CRAN, PyPI, Conda, NPM, Maven, etc.
#' see https://ossindex.sonatype.org/ecosystems for full list.
#'
#' @param pkg A vector of package names to search in the OSS Index.
#' @param version The specific package version to search for.
#' By default it will search all known versions. If not `*`, must be the same length as pkg.
#' @param type The package management environment.
#' This defaults to \code{"cran"}. See https://ossindex.sonatype.org/ecosystems.
#' @param verbose Default \code{TRUE}.
#'
#' @export
audit_pkgs = function(pkg, version = "*", type = "cran", verbose = TRUE) {

  # create the purls. Checks will be inherited
  purls = gen_purls(pkg, version, type)
  audit = call_oss_index(purls, verbose = verbose)
  return(audit)
}
