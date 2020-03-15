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


# Scans R packages and creates a list of purls.
# List format required for httr call
#' @importFrom tibble as_tibble tibble
#' @importFrom utils installed.packages packageVersion
get_purls = function() {
  ip = tibble::as_tibble(installed.packages()[, c(1, 3:4)])
  ip = ip[is.na(ip$Priority), ]

  # Extract Package and Version columns
  purls = paste0("pkg:cran/", ip$Package, "@", ip$Version)
  purls = as.list(purls)
  return(purls)
}


#' @title Check Package Dependencies
#'
#' Collects R dependencies and checks them against OSS Index.
#' Returns a tibble of results.
#' @param verbose Default \code{TRUE}.
#' @export
audit_deps = function(verbose = TRUE) {
  purls = get_purls()
  results = call_oss_index(purls)

  if (isTRUE(verbose)) {
    audit_deps_verbose(results)
  }
  return(results)
}

#' @title Extract Vulnerabilities
#'
#' Parse the audit data frame, and extract
#' the vulnerabilities.
#' @param audit Output from \code{audit_deps}.
#' @export
get_vulnerabilies = function(audit) {
  if (sum(audit$no_of_vulnerabilites) == 0) {
    return(tibble(cvss_id = character(0), cvss_title = character(0),
                  cvss_description = character(0), cvss_score = character(0),
                  cvss_vector = character(0), cvss_cwe = character(0),
                  cvss_reference = character(0)))
  }

  audit$vulnerabilites = audit$vulnerabilites %>%
    map(~ map_dfr(.x, ~tibble(cvss_id = .x[[1]],
                              cvss_title = .x[[2]],
                              cvss_description = .x[[3]],
                              cvss_score = .x[[4]],
                              cvss_vector = .x[[5]],
                              cvss_cwe = .x[[6]],
                              cvss_reference = .x[[7]])))
  tidyr::unnest(audit, vulnerabilites)
}


