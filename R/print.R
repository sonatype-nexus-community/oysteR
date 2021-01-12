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

globalVariables(c("no_of_pkgs", "no_of_vul", "no_of_vul_comps", "pkgs_in_sona"))
audit_verbose = function(results) {
  no_of_pkgs = nrow(results)
  no_of_vul_comps = sum(results$no_of_vulnerabilities != 0)
  no_of_vul = sum(results$no_of_vulnerabilities)
  pkgs_in_sona = sum(!is.na(results$description))

  cli::cli_h2("Vulnerability overview")
  cli::cli_alert_info("{no_of_pkgs} package{?s} w{?as/ere} scanned")
  cli::cli_alert_info("{pkgs_in_sona} package{?s} w{?as/ere} found in the Sonatype database")
  cli::cli_alert_info("{no_of_vul_comps} package{?s} had known vulnerabilit{?y/ies}")
  cli::cli_alert_info("A total of {no_of_vul} known vulnerabilit{?y/ies} w{?as/ere} identified")
  cli::cli_alert_info("See https://github.com/sonatype-nexus-community/oysteR/ for details.")
  return(invisible(NULL))
}
