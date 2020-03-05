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

library("httr")
library("rjson")

collect_dependencies_and_turn_into_purls <- function() {
  ip = as.data.frame(installed.packages()[,c(1,3:4)])
  ip = ip[is.na(ip$Priority),0:2,drop=FALSE]

  purls <- list()
  for(row in 1:nrow(ip)) {
    name <- ip[row, 1]
    version <- ip[row, 2]

    purl <- sprintf("pkg:cran/%s@%s", name, version)
    purls <- append(purls, purl)
  }
  return(purls)
}

call_oss_index <- function(purls) {
  OSS_INDEX_URL <- "https://ossindex.sonatype.org/api/v3/component-report"

  BODY <- list(coordinates = purls)

  r <- httr::POST(OSS_INDEX_URL, body = BODY, encode = "json")

  result <- rjson::fromJSON(httr::content(r, "text", encoding="UTF-8"))
  return(result)
}

audit_response_from_oss_index <- function(response) {
  vulnerableComponents <- extract_vulnerable_components(response)

  numberOfComponents <- length(response)
  numberOfVulnerableComponents <- length(vulnerableComponents)
  numberOfVulnerabilities <- 666666

  print_summary(numberOfComponents, numberOfVulnerableComponents, numberOfVulnerabilities)

  for(i in response) {
    vulnerabilities <- i$vulnerabilities
    numberOfVulnsForThisComponent <- length(vulnerabilities)
    if (numberOfVulnsForThisComponent > 0) {
      coordinates <- i["coordinates"]
      cat(sprintf("\n===\nVulnerabilities were detected for the component: %s\n===\n\n", coordinates))
      cat(sprintf("*  Coordinates: %s\n", coordinates))
      cat(sprintf("*  Reference: %s\n", i["reference"]))
      cat(sprintf("*  Description: %s\n\n", i["description"]))
      cat(sprintf("*  Vulnerabilities (total of %d): \n", numberOfVulnsForThisComponent))
      print_vulnerability(vulnerabilities, coordinates)
    }
  }
}

extract_vulnerable_components <- function(allComponents) {
  return(Filter(function(l) length(l$vulnerabilities) > 0, allComponents))
}

print_summary <- function(numberOfComponents, numberOfVulnerableComponents, numberOfVulnerabilities) {
  pluralizer = ""
  if (numberOfVulnerableComponents == 1) {
    pluralizer = "s"
  }

  cat("\nSonabot here, beep boop beep boop, here are the results from OSS Index:\n")
  cat(sprintf("  %d components were detected, of which %d contain%s known vulnerabilities.\n", numberOfComponents, numberOfVulnerableComponents, pluralizer))
  cat(sprintf("  A total of %d known vulnerabilities were identified.\n", numberOfVulnerabilities))
}

print_vulnerability <- function(vulnerabilities, name) {
  for(i in vulnerabilities) {
    cat("\n")
    cat(sprintf("    CWE: %s\n", i["cwe"]))
    cat(sprintf("    Title: %s\n", i["title"]))
    cat(sprintf("    Description: %s\n", i["description"]))
    cat(sprintf("    CVSS Score: %s\n", i["cvssScore"]))
    cat(sprintf("    CVSS Vector: %s\n", i["cvssVector"]))
    cat(sprintf("    ID: %s\n", i["id"]))
    cat(sprintf("    Reference: %s\n", i["reference"]))
  }
}

audit_deps_with_oss_index <- function() {
  purls <- collect_dependencies_and_turn_into_purls()
  res <- call_oss_index(purls)
  audit_response_from_oss_index(res)
}

audit_deps_with_oss_index()
