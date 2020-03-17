#' @importFrom httr status_code POST
#' @importFrom rjson fromJSON
# Check status code
check_status_code = function(r) {
  status_code = httr::status_code(r)
  if (status_code == 401) {
    stop("Invalid credentials for OSS Index.
         Please check your username and API token and try again.", call. = FALSE)
  } else if (status_code == 429) {
    stop("You've made too many requests.
         Please wait and try again later,
         or use your OSS Index credentials to bypass the rate limits.", call. = FALSE)
  } else if (status_code == 400) {
    stop("The OSS Index API returned a status code of 400: Bad Request.
         Check the format of the purls in your request.
         See also: https://ossindex.sonatype.org/doc/rest", call. = FALSE)
  } else if (status_code != 200) {
    content = httr::content(r, "text", encoding = "UTF-8")
    msg = glue::glue("There was some problem connecting to the OSS Index API.\\
                The server responded with:
                  Status Code: {status_code}
                  Response Body:{content}")
    stop(msg, call. = FALSE)
  }
  return(invisible(NULL))
}

# Just pass NULL to POST if no authentication
get_post_authenticate = function(verbose) {
  user = Sys.getenv("OSSINDEX_USER", NA)
  token = Sys.getenv("OSSINDEX_TOKEN", NA)
  if (!is.na(user) && !is.na(token)) {
    authenticate = httr::authenticate(user, token, type = "basic")
  } else {
    authenticate = NULL
  }

  if (isTRUE(verbose)) {
    if (!is.null(authenticate)) {
      cli_alert("Using Sonatype tokens")
    } else {
      cli_alert("No Sonatype tokens found")
    }
  }
  return(authenticate)
}

globalVariables("vulnerabilities")
#' @importFrom dplyr bind_rows mutate
#' @importFrom purrr map map_dbl
#' @importFrom dplyr %>%
call_oss_index = function(purls, verbose) {
  max_size = 128
  os_index_url = "https://ossindex.sonatype.org/api/v3/component-report"

  if (isTRUE(verbose)) {
    cli_h2("Calling sonatype API")
  }
  authenticate = get_post_authenticate(verbose)
  no_of_batches = ceiling(length(purls) / max_size)
  results = list()
  for (i in seq_len(no_of_batches)) {
    start = ((i - 1) * max_size + 1)
    end = min(i * max_size, length(purls))
    if (isTRUE(verbose)) {
      cli_alert_info("Calling API: batch {i} of {no_of_batches}")
    }

    body = list(coordinates = purls[start:end])
    r = httr::POST(os_index_url, body = body, encode = "json", authenticate)
    check_status_code(r)
    batchResult = rjson::fromJSON(httr::content(r, "text", encoding = "UTF-8"))
    results = c(results, batchResult)

  }

  # Return as a tibble for easier manipulation
  # Handle edge case
  if (length(results) == 0) {
    results = tibble::tibble(package = character(0), description = character(0),
                             reference = character(0), vulnerabilities = list(),
                             no_of_vulnerabilities = integer(0))
  } else {

    results = purrr::map(results, ~tibble::tibble(package = .x[[1]],
                                                  description = .x[[2]],
                                                  reference = .x[[3]],
                                                  vulnerabilities = .x[4])) %>%
      dplyr::bind_rows() %>%
      mutate(no_of_vulnerabilities = purrr::map_dbl(vulnerabilities, length))
  }

  class(results) = c("oysteR_deps", class(results))
  return(results)
}
