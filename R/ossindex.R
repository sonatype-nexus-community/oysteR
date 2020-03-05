"Copyright 2020 Sonatype Inc.

Licensed under the Apache License, Version 2.0 (the \"License\");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an \"AS IS\" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License."

library(httr)
library("rjson")

call_oss_index <- function(purls) {
  OSS_INDEX_URL <- "https://ossindex.sonatype.org/api/v3/component-report"

  BODY <- list(coordinates = purls)

  r <- httr::POST(OSS_INDEX_URL, body = BODY, encode = "json")

  result <- rjson::fromJSON(content(r, "text", encoding="UTF-8"))
  return(result)
}
