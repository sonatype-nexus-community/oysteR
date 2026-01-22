get_token = function(token, verbose = TRUE) {
  if (is.null(token)) {
    user = Sys.getenv("OSSINDEX_USER", NA)
    token = Sys.getenv("OSSINDEX_TOKEN", NA)
    if (!is.na(user) && !is.na(token)) {
      token = list(user = user, token = token)
    }
  } else if (is.null(token) && file.exists("~/.ossindex/.oss-index-config")) {
    config = yaml::read_yaml("~/.ossindex/.oss-index-config")
    token = list(user = config$ossi$Username, token = config$ossi$Token)
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

get_ossindex_url = function(ossindex_url = NULL) {
  # If URL is explicitly provided, use it
  if (!is.null(ossindex_url)) {
    return(ossindex_url)
  }

  # Check environment variable
  env_url = Sys.getenv("OSSINDEX_URL", NA)
  if (!is.na(env_url)) {
    return(env_url)
  }

  # Check config file
  if (file.exists("~/.ossindex/.oss-index-config")) {
    config = yaml::read_yaml("~/.ossindex/.oss-index-config")
    if (!is.null(config$ossi$Url)) {
      return(config$ossi$Url)
    }
  }

  # Default URL
  return("https://ossindex.sonatype.org/api/v3/component-report")
}
