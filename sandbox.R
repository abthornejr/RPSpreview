# sandbox.R

# Install Dependencies
#
# install.packages("httr")
# install.packages("base64enc")
# install.packages("XML")
# install.packages("R6")

#### START HERE ####

# Load libraries

library("httr")
library("base64enc")
library("XML")
library("R6")

source("PSconnClass.R")

conn = PSCONN$new()

conn

conn$check.API()

conn$check.login()
conn$update()
ct = conn$count.assignments()

students <- conn$current.students()

students

stu = XML::xmlToList(students)
stu[1]
stu[1]$student$name

# resp = httr::GET(url = paste0(conn$get.site(),"ws/schema/table"),
#           add_headers(.headers = c(Authorization=paste0("Bearer ",conn$get.authBearer()))),
#           accept_json())
# content(resp)
# qq = jsonlite::fromJSON(rawToChar(resp$content))
# qq
# rr = xmlParse(rawToChar(resp$content))
# rr
# #qq = xmlToList(rr)
# #qq
# ss = xmlToDataFrame(rr)
# ss
