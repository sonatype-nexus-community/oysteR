# Copyright 2020 Sonatype Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License."

#' @importFrom httr status_code POST
#' @importFrom rjson fromJSON
# Check status code
check_status_code = function(r) {
  status_code = httr::status_code(r)
  if (status_code == 401) {
    stop("Invalid credentials for Nexus IQ Server.
         Please check your username and API token and try again.", call. = FALSE) # nocov
  } else if (status_code == 400) {
    stop("The Nexus IQ Server returned a status code of 400: Bad Request.
         Check the format of your request.", call. = FALSE) # nocov
  } else if (status_code != 200) {
    content = httr::content(r, "text", encoding = "UTF-8")
    msg = glue::glue("There was some problem connecting to the Nexus IQ Server API.\\
                The server responded with:
                  Status Code: {status_code}
                  Response Body: {content}")
    stop(msg, call. = FALSE)
  }
  return(invisible(NULL))
}

# Almost identical to OSS Index one, can likely accept some variables to be shared
# As well, the IQ Server config has a Server string, which can be used for the host
get_config = function() {
  config = yaml::read_yaml("~/.iqserver/.iq-server-config")
  if (is.null(config$iq$Username) ||
      is.null(config$iq$Token)) {
    return(NULL)
  }

  httr::authenticate(config$iq$Username,
                     config$iq$Token,
                     type = "basic")
}

# Same as OSS Index one, although we can expand the User Agent, IQ Server accepts more values (OS, etc...)
#' @importFrom httr user_agent
#' @importFrom utils packageVersion
#' @keywords internal
get_user_agent = function() {
  version = utils::packageVersion("oysteR")
  ua = paste0("oysteR/", version)
  return(httr::user_agent(ua))
}

call_iq_server = function(sbom, host, application, attempts = 300, verbose) {
  if (isTRUE(verbose)) cli::cli_h2("Calling sonatype API: https://www.sonatype.com/")

  os_index_url = "https://ossindex.sonatype.org/api/v3/component-report"

  authenticate = get_post_authenticate(verbose)
  user_agent = get_user_agent()

  if (isTRUE(verbose)) {
    cli::cli_alert_info("Getting internal application ID")
  }

  application_api_url = str_interp("${host}/api/v2/applications?publicId=${application}")

  r = httr::GET(application_api_url, user_agent, authenticate)
  check_status_code(r)

  # From this application result you should have JSON like:
  # {
  #   "applications": [
  #     {
  #       "id": "4537e6fe68c24dd5ac83efd97d4fc2f4",
  #       "publicId": "MyApplicationID",
  #       "name": "MyApplication",
  #       "organizationId": "bb41817bd3e2403a8a52fe8bcd8fe25a",
  #       "contactUserName": "NewAppContact",
  #       "applicationTags": [
  #         {
  #           "id": "9beee80c6fc148dfa51e8b0359ee4d4e",
  #           "tagId": "cfea8fa79df64283bd64e5b6b624ba48",
  #           "applicationId": "4bb67dcfc86344e3a483832f8c496419"
  #         }
  #       ]
  #     }
  #   ]
  # }
  # It is safe to take the first result from the array so applications[0], and save the ID for use in the rest of the calls
  applicationResult = rjson::fromJSON(httr::content(r, "text", encoding = "UTF-8"))

  # 100% sure I am doing this wrong, but pseudo code
  applicationInternalId = applicationResult$applications[0]$id

  application_third_party_url = str_interp("${host}/api/v2/scan/applications/${applicationInternalId}/sources/oysteR?stageId=development")

  r = httr::POST(application_third_party_url, body = sbom, user_agent, authenticate)
  check_status_code(r)

  # From this third party call, you should have JSON like:
  # {
  #   "statusUrl": "api/v2/scan/applications/a20bc16e83944595a94c2e36c1cd228e/status/9cee2b6366fc4d328edc318eae46b2cb"
  # }
  # The statusURL is what we will short poll (once a second, for a configurable amount of tries, defaulting to likely 300)
  thirdPartyResult = rjson::fromJSON(httr::content(r, "text", encoding = "UTF-8"))

    # 100% sure I am doing this wrong, but pseudo code
  statusURL = str_interp("${host}/${thirdPartyResult$statusUrl}")

  tries <- 0
  while (tries < attempts) {
    r = httr::GET(statusURL, user_agent, authenticate)

    status_code = httr::status_code(r)
    if (status_code == 200) {
      reportDetails = rjson::fromJSON(httr::content(r, "text", encoding = "UTF-8"))

      # Ideally we'd return here, as this json has the HTML link to see your report in IQ Server
      return(reportDetails)
      break
    } else if (status_code == 404) {
      # Sleep for one second (so we don't DDOS Iq Server)
      tries = tries + 1
      Sys.sleep(1)
    } else {
      # Any other status code is indicative of some failure, so 401, 500 etc... so we are safe to quit looping
      break
    }
  }
}
