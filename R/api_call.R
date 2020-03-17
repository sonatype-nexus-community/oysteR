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
    msg = glue("There was some problem connecting to the OSS Index API.\\
                The server responded with:
                  Status Code: {status_code}
                  Response Body:{content}")
    stop(msg, call. = FALSE)
  }
  return(invisible(NULL))
}

# Returns the batch number each purl belongs to.
# E.g. A vector 1, 1, 1, ..., 2, 2, ...
# Could probably just do a while loop
batch_purls = function(purls) {
  max_size = 128
  no_batches = ceiling(length(purls) / max_size)
  batch_no = rep(seq_len(no_batches), each = max_size)
  batch_no = batch_no[seq_along(purls)]
  return(batch_no)
}

globalVariables("vulnerabilities")
#' @importFrom dplyr bind_rows mutate
#' @importFrom purrr map map_dbl
#' @importFrom dplyr %>%
call_oss_index = function(purls) {
  os_index_url = "https://ossindex.sonatype.org/api/v3/component-report"
  user = Sys.getenv("OSSINDEX_USER", NA)
  token = Sys.getenv("OSSINDEX_TOKEN", NA)

  batch_no = batch_purls(purls)
  results = list()
  for (i in unique(batch_no)) {

    body = list(coordinates = purls[batch_no == i])
    if (!is.na(user) && !is.na(token)) {
      r = httr::POST(os_index_url, body = body, encode = "json",
                      httr::authenticate(user, token, type = "basic"))
    } else {
      r = httr::POST(os_index_url, body = body, encode = "json")
    }
    check_status_code(r)
    batchResult = rjson::fromJSON(httr::content(r, "text", encoding = "UTF-8"))
    results = c(results, batchResult)
  }

  # Return as a tibble for easier manipulation
  results = purrr::map(results, ~tibble::tibble(package = .x[[1]],
                                                description = .x[[2]],
                                                reference = .x[[3]],
                                                vulnerabilities = .x[4])) %>%
    dplyr::bind_rows() %>%
    mutate(no_of_vulnerabilities = purrr::map_dbl(vulnerabilities, length))

  class(results) = c("oysteR_deps", class(results))
  return(results)
}
