get_token = function(token, verbose = TRUE) {
  if (is.null(token)) {
    token = get_env_token()
  }
  if (is.null(token)) {
    token = get_config_token()
  }

  if (isTRUE(verbose)) {
    if (!is.null(token)) {
      cli::cli_alert("Using Sonatype tokens")
    } else {
      cli::cli_alert("No Sonatype tokens found")
    }
  }
  token
}

get_env_token = function() {
  make_token(Sys.getenv("OSSINDEX_USER"), Sys.getenv("OSSINDEX_TOKEN"))
}

get_config_token = function(path = "~/.ossindex/.oss-index-config") {
  if (!file.exists(path)) {
    return(NULL)
  }
  config = yaml::read_yaml(path)
  make_token(config$ossi$Username, config$ossi$Token)
}

# Returns NULL unless both credentials are non-empty strings
make_token = function(user, token) {
  is_valid = function(x) is.character(x) && length(x) == 1L && !is.na(x) && nzchar(x)
  if (!is_valid(user) || !is_valid(token)) {
    return(NULL)
  }
  list(user = user, token = token)
}
