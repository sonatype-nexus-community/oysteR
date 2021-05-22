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

# Helper function: adds a node!
add_child_node = function(parent, node_name, node_text = NULL) {
  new_node = xml2::xml_new_root(node_name)
  if (!is.null(node_text)) xml2::xml_text(new_node) = node_text
  xml2::xml_add_child(parent, new_node)
}

# Header text. Only thing that varies is package version
get_root_node = function() {
  root = xml2::xml_new_root("bom", xmlns = "http://cyclonedx.org/schema/bom/1.3")
  metadata = add_child_node(root, "metadata")
  tools = add_child_node(metadata, "tools")
  tool = add_child_node(tools, "tool")
  add_child_node(tool, "vendor", node_text = "sonatype-nexus-community")
  add_child_node(tool, "name", node_text = "oysteR")
  add_child_node(tool, "version", node_text = as.character(packageVersion("oysteR")))
  root
}

# Creates a purl XML component
get_component = function(purl) {
  purl_split = stringr::str_match(purl, pattern = "pkg:(.+)@(.+)")
  purl_name = purl_split[1, 2]
  purl_version = purl_split[1, 3]
  component = xml2::xml_new_root("component", type = "library", "bom-ref" = purl)
  add_child_node(component, "name", purl_name)
  add_child_node(component, "version", purl_version)
  add_child_node(component, "purl", purl)
  component
}


# To test:
# purls = oysteR:::generate_purls(c("widgetframe", "drat"), c("0.3.1", "0.1"), "cran")
# xml = create_sbom(purls)
# cat(as.character(xml))
create_sbom = function(purls, verbose = TRUE) {
  if (isTRUE(verbose)) {
    cli::cli_alert("Beginning to create CycloneDX SBOM")
  }

  root = get_root_node()
  components = xml2::xml_add_child(root, "components")
  for (purl in purls) {
    component = get_component(purl)
    add_child_node(components, component)
  }
  if (isTRUE(verbose)) {
    cli::cli_alert("Finished with CycloneDX SBOM")
  }

  #cat(as.character(root))
  return(root)
}


##############################
# To delete before merging
# Uses XML

# create_sbom = function(purls, verbose) {
#   library(XML)
#   if (isTRUE(verbose)) {
#     cli::cli_alert("Beginning to create CycloneDX SBOM")
#   }
#
#   bom = newXMLNode("bom", attrs=c(xmlns='http://cyclonedx.org/schema/bom/1.3'))
#   metadata = newXMLNode("metadata", parent=bom)
#   tools = newXMLNode("tools", parent=metadata)
#   tool = newXMLNode("tool", parent=tools)
#   newXMLNode("vendor", "sonatype-nexus-community", parent=tool)
#   newXMLNode("name", "oysteR", parent=tool)
#   # Need to obtain the oysteR version for this
#   newXMLNode("version", "oysteR-Version", parent=tool)
#
#   components = newXMLNode("components", parent=bom)
#   for (purl in purls) {
#     component = newXMLNode("component", attrs=c(type='library', 'bom-ref'=purl), parent=components)
#     # Need to split the PURL to have the name/version for use here
#     newXMLNode("name", "name-value", parent=component)
#     newXMLNode("version", "version-value", parent=component)
#     newXMLNode("purl", purl, parent=component)
#   }
#
#   if (isTRUE(verbose)) {
#     cli::cli_alert("Finished with CycloneDX SBOM")
#   }
#
#   bom
# }
