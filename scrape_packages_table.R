library(rvest)
library(dplyr)
library(purrr)

url <- "https://cran.microsoft.com/snapshot/2015-01-01/web/packages/available_packages_by_date.html"

packages <- url %>%
  read_html() %>%
  html_table(fill = TRUE) %>%
  pluck(1)

head(packages)

package_url <- "https://cran.microsoft.com/snapshot/2015-01-01/web/packages/bibtex/index.html"


package_source_url <- package_url %>%
  read_html() %>%
  html_nodes("table") %>%
  html_nodes("a") %>%
  html_attr("href") %>%
  keep(., ~grepl("src.*contrib.*tar.gz", .))

