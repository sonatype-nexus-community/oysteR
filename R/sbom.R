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

library(XML)

create_sbom = function(purls, verbose) {
  if (isTRUE(verbose)) {
    cli::cli_alert("Beginning to create CycloneDX SBOM")
  }

  bom = newXMLNode("bom", attrs=c(xmlns='http://cyclonedx.org/schema/bom/1.3'))
  metadata = newXMLNode("metadata", parent=bom)
  tools = newXMLNode("tools", parent=metadata)
  tool = newXMLNode("tool", parent=tools)
  newXMLNode("vendor", "sonatype-nexus-community", parent=tool)
  newXMLNode("name", "oysteR", parent=tool)
  # Need to obtain the oysteR version for this
  newXMLNode("version", "oysteR-Version", parent=tool)

  components = newXMLNode("components", parent=bom)
  for (purl in purls) {
    component = newXMLNode("component", attrs=c(type='library', 'bom-ref'=purl), parent=components)
    # Need to split the PURL to have the name/version for use here
    newXMLNode("name", "name-value", parent=component)
    newXMLNode("version", "version-value", parent=component)
    newXMLNode("purl", purl, parent=component)
  }

  if (isTRUE(verbose)) {
    cli::cli_alert("Finished with CycloneDX SBOM")
  }

  bom
}
