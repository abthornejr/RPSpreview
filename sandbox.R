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

students <- conn$all.students()

students
