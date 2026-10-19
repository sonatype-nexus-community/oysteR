# OSS Index no longer accepts anonymous requests
skip_if_no_token = function() {
  if (is.null(get_env_token()) && is.null(get_config_token())) {
    testthat::skip("No OSS Index credentials")
  }
}
