
globalVariables(c("no_of_pkgs", "no_of_vul", "no_of_vul_comps", "pkgs_in_sona"))
#' @import cli
audit_deps_verbose = function(results) {
  no_of_pkgs = nrow(results)
  no_of_vul_comps = sum(results$no_of_vulnerabilities != 0)
  no_of_vul = sum(results$no_of_vulnerabilities)
  pkgs_in_sona = sum(!is.na(results$description))

  cli_h2("Vulnerability overview")
  cli_alert_info("{no_of_pkgs} package{?s} were scanned")
  cli_alert_info("{pkgs_in_sona} package{?s} were in the Sonatype database")
  cli_alert_info("{no_of_vul_comps} package{?s} contains known vulnerabilit{?y/ies}")
  cli_alert_info("A total of {no_of_vul} known vulnerabilit{?y/ies} w{?as/ere} identified")
  return(invisible(NULL))
}
