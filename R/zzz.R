.onAttach = function(...) { #nolint
  if (!interactive()) return()
  packageStartupMessage("See https://www.sonatype.com/ for details.")
}
