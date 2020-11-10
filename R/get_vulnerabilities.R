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
#
#' @title Extract vulnerabilities
#'
#' @description Parse the audit data frame (obtained via \code{audit_deps}), and extract
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
#' #deps = audit_deps(pkgs)
#' #get_vulnerabilities(deps)
#' }
get_vulnerabilities = function(audit) {
  if (sum(audit$no_of_vulnerabilities) == 0) {
    return(tibble(package = character(0), version = character(0), type = character(0),
                  oss_package = character(0), description = character(0),
                  reference = character(0),
                  cvss_id = character(0), cvss_title = character(0),
                  cvss_description = character(0), cvss_score = character(0),
                  cvss_vector = double(0), cvss_cwe = character(0),
                  cvss_reference = character(0),
                  no_of_vulnerabilites = integer(0)))
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
