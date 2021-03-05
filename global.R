# the necessary packages----
library(DT)
library(RPostgres)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(tidyverse)
library(hrbrthemes)

# # # connect to the kpop database----
# con <- dbConnect(
#   drv = dbDriver('Postgres'),
#   dbname = 'kpop',
#   host = 'db-postgresql-nyc1-44203-do-user-8018943-0.b.db.ondigitalocean.com',
#   port = 25060,
#   user = 'doadmin',
#   password = 'ayxhea1w79p562zx'
# )

#_create a local connection to BMW database


con <- dbConnect(
  drv = dbDriver('Postgres'),
  dbname = 'kpop',
  host = 'localhost',
  port = 5432,
  user = 'postgres',
  password = '123'
)


# the list of artists----
artsts <- c(
  'Apink',
  'BIGBANG', 
  'BLACKPINK', 
  'BTS', 
  'Chungha',
  'CLC',
  'Everglow',
  'EXO', 
  'GOT7',
  'iKON',
  'ITZY',
  'IU',
  'Mamamoo',
  'Oh My Girl',
  'Red Velvet',
  'Stray Kids',
  'Sunmi',
  'Twice'
)

# disconnect from the kpop database----
onStop(
  function()
  {
    dbDisconnect(con)
  }
)

