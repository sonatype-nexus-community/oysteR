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

collect_dependencies_and_turn_into_purls <- function() {
  ip = as.data.frame(installed.packages()[,c(1,3:4)])
  ip = ip[is.na(ip$Priority),0:2,drop=FALSE]

  purls <- list()
  for(row in 1:nrow(ip)) {
    name <- ip[row, 1]
    version <- ip[row, 2]

    purl <- sprintf("pkg:cran/%s@%s", name, version)
    purls <- append(purls, purl)
  }
  return(purls)
}
