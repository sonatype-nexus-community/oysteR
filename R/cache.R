get_cache_dir = function() {
  R_user_dir = utils::getFromNamespace("R_user_dir", "tools")
  R_user_dir("oysteR", which = "cache")
}

get_cache_file = function() {
  dir = get_cache_dir()
  path = file.path(dir, "cached-deps.rds")
  return(path)
}

ensure_cache = function() {
  path = get_cache_file()
  if (file.exists(path)) return(path)

  dir.create(get_cache_dir(), recursive = TRUE, showWarnings = FALSE)
  audits = no_purls_case()
  audits$time = integer(0)
  class(audits$time) = c("POSIXct", "POSIXt")
  saveRDS(audits, file = path)
  return(path)
}

## General cache idea
## 1. Use R 4 to get a a cache directory - works across all OSs
## 2. Add a timestamp of when the results were obtained
## 3. Future calls would read the cache and prune as necessary
## 4. Store cache as an rds file - very efficient R binary file.
#' @importFrom rlang .data
get_cache = function() {
  ## Only available for R4+
  if (getRversion() < "4.0.0") return(no_purls_case())
  path = ensure_cache()
  audits = readRDS(path) %>%
    dplyr::filter(.data$time > Sys.time() - 60 * 60 * 12) %>%
    dplyr::select(-.data$time)
  audits
}

update_cache = function(audits) {
  if (getRversion() < "4.0.0") return(audits)
  audits$time = Sys.time()
  path = ensure_cache()

  old_audit = readRDS(path)
  audits = old_audit %>%
    dplyr::filter(.data$time > Sys.time() - 60 * 60 * 12) %>% #12 hour caching time
    dplyr::filter(!(.data$oss_package %in% audits$oss_package)) %>%
    dplyr::bind_rows(audits)

  saveRDS(audits, file = path)
  return(audits)
}

#' Remove cache
#'
#' The OSS cache is located at `tools::R_user_dir("oysteR", which = "cache")`.
#' The function `R_user_dir()` is only available for R >= 4.0.0.
#' Packages are cached for 12 hours, then refreshed at the next audit
#' @export
remove_cache = function() {
  path = get_cache_file()
  if (file.exists(path)) file.remove(path)
  return(NULL)
}
