library(tidyverse)

library(jsonlite)
library(rvest)

'https://www.cismef.org/page/cas-clinique'
'https://wwwfbm.unil.ch/enseignement/vignettes/'
'https://www.prevention-medicale.org/cas-cliniques-et-retours-d-experience/Tous-les-cas-cliniques'
'http://www.efurgences.net/seformer/cas-cliniques.html'





json <- jsonlite::read_json('result.json')

url <- json[[155]]$URL

url <- 'https://www.pediatrie-pratique.com/journal/articles-par-theme/Cas%20cliniques?page=1'
#url  <- "https://www.pediatrie-pratique.com/journal/article/0011103-osteogenese-imparfaite-propos-dun-cas"

print(url)
html <- read_html(url)

base_url <- 'https://www.pediatrie-pratique.com'
links <- html %>% html_elements('.group-lien') %>% html_attr('href')

link <- links[1]
url_art <- glue::glue('{base_url}{link}')

html <- read_html(url_art)
html %>% html_element('.excerpt-content') %>% html_text2()


