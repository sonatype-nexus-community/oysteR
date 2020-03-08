#' @export
print.oysteR_deps = function(x, ...) {
  no_of_comps = nrow(x)
  no_of_vul_comps = sum(x$no_of_vulnerabilites != 0)
  no_of_vul = sum(x$no_of_vulnerabilites)

  pluralizer = ""
  if (no_of_vul_comps == 1) {
    pluralizer = "s"
  }

  res = glue::glue("Sonabot here, beep boop beep boop, here are the results from OSS Index:
        {no_of_comps} components were detected
        {no_of_vul_comps} contain{pluralizer} known vulnerabilities
        {A total of {no_of_vul} known vulnerabilities were identified")
  cat(res)
  return(x)
}


## Not really edited
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
  vulnerabilitie = vulnerabilities[1,]$vulnerabilites[[1]]
  for (i in vulnerabilitie) {
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

#' @importFrom cowsay say
print_header <- function() {
  .version <- "Development"
  cowsay::say("oysteR\n\tBy Sonatype & Friends\n\nQ: Why a shark?\nA: There wasn't an oyster :(",
              by = "shark")

  tryCatch({
    .version <- packageVersion('oysteR')
  }, warning = function(w) {
    # NO OP
  }, error = function(e) {
    # NO OP
  }, finally = {
    cat(sprintf("Version: %s\n", .version))
  })

  cat("\n")
}




audit_response_from_oss_index <- function(results) {
  #vulnerableComponents <- .extract_vulnerable_components(response)
  vulnerableComponents = results[results$no_of_vulnerabilites > 0, ]
  numberOfComponents <- nrow(results)
  numberOfVulnerableComponents <- nrow(vulnerableComponents)
  numberOfVulnerabilities <- sum(results$no_of_vulnerabilites)

  i = 1
  index <- 1
  for (i in results) {
    numberOfVulnsForThisComponent <- results$no_of_vulnerabilites[1]

    .print_component_summary(index,
                             numberOfComponents,
                             i["coordinates"],
                             numberOfVulnsForThisComponent)
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

  #.print_summary(numberOfComponents, numberOfVulnerableComponents, numberOfVulnerabilities)
  return(numberOfVulnerableComponents)
}
