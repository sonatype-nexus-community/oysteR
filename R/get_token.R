# SECURITY FIX: Corrected logic bug where config file was never read (dead code)
get_token = function(token, verbose = TRUE) {
  if (is.null(token)) {
    # First try environment variables
    user = Sys.getenv("OSSINDEX_USER", NA)
    env_token = Sys.getenv("OSSINDEX_TOKEN", NA)
    if (!is.na(user) && !is.na(env_token)) {
      token = list(user = user, token = env_token)
    } else {
      # Then try config file (was previously dead code due to logic bug)
      config_path = path.expand("~/.ossindex/.oss-index-config")
      if (file.exists(config_path)) {
        config = yaml::read_yaml(config_path)
        if (!is.null(config$ossi$Username) && !is.null(config$ossi$Token)) {
          token = list(user = config$ossi$Username, token = config$ossi$Token)
        }
      }
    }
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
