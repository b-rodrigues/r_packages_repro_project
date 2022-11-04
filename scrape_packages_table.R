library(rvest)
library(dplyr)
library(purrr)

url <- "https://cran.microsoft.com/snapshot/2015-01-01/web/packages/available_packages_by_date.html"

packages <- url %>%
  read_html() %>%
  html_table(fill = TRUE) %>%
  pluck(1)

head(packages)

root_url <- "https://cran.microsoft.com/snapshot/2015-01-01/"

package_url <- "web/packages/maxLik/index.html"

package_source_url <- paste0(root_url, package_url) %>%
  read_html() %>%
  html_nodes("table") %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  keep(., ~grepl("src.*contrib.*tar.gz", .)) %>%
  stringr::str_remove("\\.\\.\\/\\.\\.\\/\\.\\.\\/")

package_url <- paste0(root_url, package_source_url)
