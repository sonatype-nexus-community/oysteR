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

library("httr")
library("rjson")

#' Collects dependencies installed locally, and turns them into purls
#'
#' @return A list of purls
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

OSS_INDEX_URL <- "https://ossindex.sonatype.org/api/v3/component-report"
MAX_NUMBER_OF_PURLS_PER_API_CALL <- 128

#' Calls OSS Index given a list of purls
#'
#' @param allPurls A list of purls
#' @return A list of results from OSS Index
call_oss_index <- function(allPurls) {
  batchesOfPurls <- .batch_purls(allPurls)

  result <- list()
  for (batch in batchesOfPurls) {
    BODY <- list(coordinates = batch)
    r <- httr::POST(OSS_INDEX_URL, body = BODY, encode = "json", httr::authenticate("bbelle@sonatype.com", "API_TOKEN_HERE", type = "basic"))
    tryCatch({
      batchResult <- rjson::fromJSON(httr::content(r, "text", encoding="UTF-8"))
      result <- c(result, batchResult)
    }, warning = function(w) {
      print(w)
    }, error = function(e) {
      print(e)
    }, finally = {
      # NO OP
    })
  }
  return(result)
}

# Returns list of "batches". Each batch is a list of purls, with a max length of MAX_NUMBER_OF_PURLS_PER_API_CALL.
.batch_purls <- function(purls) {
  maxBatchSize = MAX_NUMBER_OF_PURLS_PER_API_CALL
  numberOfPurls <- length(purls)
  numberOfBatches <- .get_number_of_batches(numberOfPurls, maxBatchSize)
  remainder <- numberOfPurls %% maxBatchSize

  batches <- vector(mode="list")
  for (i in seq(numberOfBatches)) {
    startOfRange = 1 + maxBatchSize * (i-1)
    endOfRange = maxBatchSize + maxBatchSize * (i-1)
    if (i == numberOfBatches) {
      endOfRange = endOfRange - maxBatchSize + remainder
    }
    batches <- append(batches, list(purls[startOfRange:endOfRange]))
  }
  return(batches)
}

.get_number_of_batches <- function(numberOfPurls, maxBatchSize) {
  numberOfBatches <- numberOfPurls %/% maxBatchSize
  if (numberOfPurls %% maxBatchSize > 0) {
    numberOfBatches <- numberOfBatches + 1
  }
  return(numberOfBatches)
}

#' Audits a response from OSS Index and prints out a software bill of materials
#'
#' @param response A list of coordinates and vulnerabilities from OSS Index
audit_response_from_oss_index <- function(response) {
  vulnerableComponents <- .extract_vulnerable_components(response)

  numberOfComponents <- length(response)
  numberOfVulnerableComponents <- length(vulnerableComponents)
  numberOfVulnerabilities <- .count_vulnerabilities(vulnerableComponents)

  index <- 1
  for(i in response) {
    numberOfVulnsForThisComponent <- 0
    tryCatch({
      numberOfVulnsForThisComponent <- length(i[["vulnerabilities"]])
    }, warning = function(w) {
      print(w)
    }, error = function(e) {
      print(e)
    }, finally = {
      # NO OP
    })
    
    .print_component_summary(index, numberOfComponents, i["coordinates"], numberOfVulnsForThisComponent)
    if (numberOfVulnsForThisComponent > 0) {
      cat(sprintf("Vulnerabilities detected for this component:\n"))
      tryCatch({
        .print_vulnerabilities(i[["vulnerabilities"]])
      }, warning = function(w) {
        print(w)
      }, error = function(e) {
        print(e)
      }, finally = {
        # NO OP
      })
    }
    index <- index + 1
  }

  .print_summary(numberOfComponents, numberOfVulnerableComponents, numberOfVulnerabilities)
}

.extract_vulnerable_components <- function(allComponents) {
  tryCatch({
    result <- Filter(function(l) length(l["vulnerabilities"]) > 0, allComponents)
  }, warning = function(w) {
    print(w)
  }, error = function(e) {
    print(e)
  }, finally = {
    return(result)
  })
}

.count_vulnerabilities <- function(vulnerableComponents) {
  totalVulnerabilities <- 0
  for (component in vulnerableComponents) {
    totalVulnerabilities <- totalVulnerabilities + length(component["vulnerabilities"])
  }
  return(totalVulnerabilities)
}

.print_summary <- function(numberOfComponents, numberOfVulnerableComponents, numberOfVulnerabilities) {
  pluralizer = ""
  if (numberOfVulnerableComponents == 1) {
    pluralizer = "s"
  }

  cat("\nSonabot here, beep boop beep boop, here are the results from OSS Index:\n")
  cat(sprintf("\t%d components were detected, of which %d contain%s known vulnerabilities.\n", numberOfComponents, numberOfVulnerableComponents, pluralizer))
  cat(sprintf("\tA total of %d known vulnerabilities were identified.\n", numberOfVulnerabilities))
}

.print_component_summary <- function(index, totalItems, coordinates, numberOfVulnsForThisComponent) {
  vulnerabilitiesFound <- "No vulnerabilities found"
  if (numberOfVulnsForThisComponent > 0) {
    vulnerabilitiesFound <- sprintf("Total vulnerabilities found: %d", numberOfVulnsForThisComponent)
  }

  cat(
    sprintf(
      "[%s/%s] - %s - %s\n", 
      index, 
      totalItems, 
      coordinates, 
      vulnerabilitiesFound
    )
  )
}

.print_vulnerabilities <- function(vulnerabilities) {
  for(i in vulnerabilities) {
    cat("\n")
    cat(sprintf("\tCWE: %s\n", i["cwe"]))
    cat(sprintf("\tTitle: %s\n", i["title"]))
    cat(sprintf("\tDescription: %s\n", i["description"]))
    cat(sprintf("\tCVSS Score: %s\n", i["cvssScore"]))
    cat(sprintf("\tCVSS Vector: %s\n", i["cvssVector"]))
    cat(sprintf("\tID: %s\n", i["id"]))
    cat(sprintf("\tReference: %s\n", i["reference"]))
  }
}

audit_deps_with_oss_index <- function() {
  purls <- collect_dependencies_and_turn_into_purls()
  results <- call_oss_index(purls)
  audit_response_from_oss_index(results)
}

audit_deps_with_oss_index()
