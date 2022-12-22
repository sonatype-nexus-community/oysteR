# Initial md sketch
# Taken from https://twitter.com/hrbrmstr/status/1403287086585860100
# To think about before merging:
# 1. This could apply to any audit, not just audit_description
audit_pkg_md = function(pkg_path = ".") {

  pkg_name = read.dcf(file.path(pkg_path, "DESCRIPTION"))[[1]]

  res = oysteR::audit_description(dir = pkg_path, verbose = FALSE)

  res = res[order(res[["no_of_vulnerabilities"]], decreasing = TRUE), ]

  knitr::kable(
    data.frame(
      `Dependency` = sprintf("[%s](%s)", res[["package"]], res[["reference"]]),
      `Audited Version` = res[["version"]],
      `Repo` = res[["type"]],
      `Vulnerabilities` = res[["no_of_vulnerabilities"]],
      check.names = FALSE
    ),
    format = "markdown",
    align = "rccr",
    caption = sprintf("{oysteR} Package Dependency Audit for {%s*}", pkg_name)
  )
}
