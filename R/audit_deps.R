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
#' @export
audit_deps = function() {
  purls = get_purls()
  results = call_oss_index(purls)

  return(results)
}
