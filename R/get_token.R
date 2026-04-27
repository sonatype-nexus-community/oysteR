get_token = function(token, verbose = TRUE) {
  if (is.null(token)) {
    user = Sys.getenv("OSSINDEX_USER", NA)
    tok  = Sys.getenv("OSSINDEX_TOKEN", NA)
    if (!is.na(tok)) {
      token = list(type = "bearer", token = tok)
    } else if (file.exists("~/.ossindex/.oss-index-config")) {
      config = yaml::read_yaml("~/.ossindex/.oss-index-config")
      token  = list(type = "basic",
                    user  = config$ossi$Username,
                    token = config$ossi$Token)
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
