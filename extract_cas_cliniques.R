library(tidyverse)

library(jsonlite)
library(rvest)

## Sources 
## https://www.pediatrie-pratique.com
## https://wwwfbm.unil.ch/enseignement/vignettes/
## https://www.prevention-medicale.org/
## https://medicalforum.ch/fr/


output_dir = "raw_text"


## Pediatrie pratique

get_article <- function(link, base_url =  'https://www.pediatrie-pratique.com') {
  
  url_art <- glue::glue('{base_url}{link}')
  html <- read_html(url_art)
  html %>% html_element('.excerpt-content') %>% html_text2()
  
}

get_page_article <- function(page) {
    url <- glue::glue('https://www.pediatrie-pratique.com/journal/articles-par-theme/Cas%20cliniques?page={page}')
    html <- read_html(url)
    links <- html %>% html_elements('.group-lien') %>% html_attr('href')
    lapply(links, get_article)
}


articles_ped <- pblapply(1:3, get_page_article)


articles_ped_simp <- unique(c(articles_ped[[1]], articles_ped[[2]],articles_ped[[3]]))
articles_ped_simp <- simplify(articles_ped_simp[!is.na(articles_ped_simp)])

pblapply(1:length(articles_ped_simp), function(i) {
  base_name = "ped"
  write_file(articles_ped_simp[i], file = glue::glue('{output_dir}/{base_name}_{sprintf("%03d", i)}.txt'))
})


## unil

base_url <- "https://wwwfbm.unil.ch/enseignement/vignettes/"

html <- read_html(base_url)
links <- html %>% html_elements('td a') %>% html_attr('href')

links <- links[str_detect(links, 'vignettes_xml')]


get_article_unil <- function(link) {
  url_art <- glue::glue('{base_url}{link}')
  html <- read_html(url_art)
  html_txt_list <- html %>% html_elements('tr td') %>% html_text2()
  article <- html_txt_list[13]
  article
}

articles_unil <- pblapply(links, get_article_unil)

articles_unil <- simplify(articles_unil)

pblapply(1:length(articles_unil), function(i) {
  base_name = "unil"
  write_file(articles_unil[i], file = glue::glue('{output_dir}/{base_name}_{sprintf("%03d", i)}.txt'))
})

## prevention medicale 

base_url <- "https://www.prevention-medicale.org/"
html <- read_html(glue::glue("{base_url}cas-cliniques-et-retours-d-experience/Tous-les-cas-cliniques?page=2"))
all_links <- html %>% html_elements('a') %>% html_attr('href') 

links <- all_links[str_detect(all_links, "Tous-les-cas-cliniques/(Medecin|Sage-femme|Chirurgien|Chirurgien-dentiste)/")]

get_article_prev <- function(link, base_url= "https://www.prevention-medicale.org/") {
  html <- read_html(glue::glue('{base_url}{link}'))
  html %>% html_element('.bloc-paragraphe') %>% html_text2()
}

get_page_article_prev <- function(page) {
  base_url <- "https://www.prevention-medicale.org/"
  html <- read_html(glue::glue("{base_url}cas-cliniques-et-retours-d-experience/Tous-les-cas-cliniques?page={page}"))
  all_links <- html %>% html_elements('a') %>% html_attr('href') 

  links <- all_links[str_detect(all_links, "Tous-les-cas-cliniques/(Medecin|Sage-femme|Chirurgien|Chirurgien-dentiste)/")]
  
  res <- lapply(links, get_article_prev)
  
  Sys.sleep(2)
  
  res
  
}

articles_prev <- pblapply(2:31, get_page_article_prev)
articles_prev <- simplify(Reduce(c, articles_prev))

pblapply(1:length(articles_prev), function(i) {
  base_name = "prev"
  write_file(articles_prev[i], file = glue::glue('{output_dir}/{base_name}_{sprintf("%03d", i)}.txt'))
})

## Forum medical suisse 

class = "article-detail-content"

url <- "https://medicalforum.ch/fr/article-listing/inhaltsbereich/2031713200654487344?tx_swajournal_articlelist%5B%40widget_0%5D%5BcurrentPage%5D=2&tx_swajournal_articlelist%5Blimit%5D=500&tx_swajournal_articlelist%5Boffset%5D=10"
html <- read_html(glue::glue('{url}'))

all_links <- html %>% html_elements('main a') %>% html_attr('href') 
links <- all_links[str_detect(all_links, "detail/doi")]
links <- links[!is.na(links)]
links <- unique(links)

get_article_smf <- function(link) {
  Sys.sleep(1)
  base_url <- "https://medicalforum.ch"
  html <- read_html(glue::glue('{base_url}{link}'))
  html %>% html_element('.article-detail-content') %>% html_text2()
  
}

articles_smf <- pblapply(links, get_article_smf) 

bla <- simplify(articles_smf)
bla <- bla[bla != ""]
bla <- bla [!str_detect(bla, 'Fallbeschreibung|Hintergrund')]

pblapply(1:length(bla), function(i) {
  base_name = "smf"
  write_file(bla[i], file = glue::glue('{output_dir}/{base_name}_{sprintf("%03d", i)}.txt'))
})


