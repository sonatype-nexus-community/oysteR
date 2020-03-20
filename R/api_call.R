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

no_purls_case = function(verbose) {
  results = tibble::tibble(package = character(0), description = character(0),
                           reference = character(0), vulnerabilities = list(),
                           no_of_vulnerabilities = integer(0))
  class(results) = c("oysteR_deps", class(results))
  return(results)
}

clean_response = function(entry) {
  if (is.null(entry$coordinates)) entry$coordinates = ""
  if (is.null(entry$description)) entry$description = ""
  if (is.null(entry$reference)) entry$reference = ""
  no_of_vulnerabilities = length(entry$vulnerabilities)
  entry$vulnerabilities = list(entry$vulnerabilities)
  tibble::tibble(oss_package = entry$coordinates,
                 description = entry$description,
                 reference = entry$reference,
                 vulnerabilities = entry$vulnerabilities,
                 no_of_vulnerabilities = no_of_vulnerabilities)
}

globalVariables("vulnerabilities")
#' @importFrom dplyr bind_rows mutate
#' @importFrom purrr map map_dbl
#' @importFrom dplyr %>%
call_oss_index = function(purls, verbose) {
  if (length(purls) == 0L) return(no_purls_case(verbose))
  if (isTRUE(verbose)) cli_h2("Calling sonatype API: https://www.sonatype.com/")

  max_size = 128
  os_index_url = "https://ossindex.sonatype.org/api/v3/component-report"

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

  results = purrr::map(results, clean_response) %>%
    dplyr::bind_rows()
  class(results) = c("oysteR_deps", class(results))
  return(results)
}
