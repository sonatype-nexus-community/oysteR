.onAttach = function(...) { #nolint
  if (!interactive()) return()
  packageStartupMessage("See https://github.com/sonatype-nexus-community/oysteR/ for details.")
}
