"Copyright 2020 Sonatype Inc.

Licensed under the Apache License, Version 2.0 (the \"License\");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an \"AS IS\" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License."

audit_response_from_oss_index <- function(response) {
  cat("Sonabot here, beep boop beep boop, here are the results from OSS Index\n")
  for(i in response) {
    cat("\n")
    cat(sprintf("Coordinates: %s\n", i$coordinates))
    cat(sprintf("Description: %s\n", i$description))
    cat(sprintf("Reference: %s\n", i$reference))
    if (length(i$vulnerabilities) > 0) {
      print_vulnerability(i$vulnerabilities)
    }
    cat("\n")
  }
}

print_vulnerability <- function(vulnerabilities) {
  cat("\n")
  cat("Vulnerability found\n")
  for(i in vulnerabilities) {
    cat("\n")
    cat(sprintf("ID: %s\n", i$id))
    cat(sprintf("Title: %s\n", i$title))
    cat(sprintf("Description: %s\n", i$description))
    cat(sprintf("CVSS Score: %s\n", i$cvssScore))
    cat(sprintf("CVSS Vector: %s\n", i$cvssVector))
    cat(sprintf("CWE: %s\n", i$cwe))
    cat(sprintf("Reference: %s\n", i$reference))
  }
}
