#' @importFrom clisymbols symbol
#' @importFrom glue glue
circle = clisymbols::symbol$circle_filled

audit_deps_verbose = function(results) {
  no_of_pkgs = nrow(results)
  no_of_vul_comps = sum(results$no_of_vulnerabilities != 0)
  no_of_vul = sum(results$no_of_vulnerabilities)
  message(glue::glue("  {circle} {no_of_pkgs} packages were scanned"))
  message(glue::glue("  {circle} {no_of_vul_comps} packages contains known vulnerabilities"))
  message(glue::glue("  {circle} A total of {no_of_vul} known vulnerabilities were identified"))
  return(invisible(NULL))
}
