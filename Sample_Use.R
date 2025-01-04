#####Install and Load Packages#####
install.packages("data.table")
install.packages("sqldf")
install.packages("plyr")
install.packages("dplyr")
install.packages("Hmisc")
install.packages("png")
install.packages("ggpubr")

library("data.table")
library("sqldf")
library("plyr")
library("dplyr")
library("ggplot2")
library("Hmisc")
library(png)
library(ggpubr)
library(grid)

pacman::p_load(devtools, usethis, Hmisc, roxygen2, testthat, knitr, rmarkdown)

install.packages(c("devtools", "roxygen2","usethis", "testthat"))
library(devtools)
library(testthat)
library(roxygen2)
library(usethis)
library(testthat)

#####Example#####
setwd("/Users/jamesgow/Desktop/ice_test")
Image_Process("MadhavRamesh_PreT.png", "MadhavRamesh_Pre", "T")
Image_Process("MadhavRamesh_PostT.png", "MadhavRamesh_Post", "T")
Image_Process("MadhavRamesh_PreC.png", "MadhavRamesh_Pre", "C")
Image_Process("MadhavRamesh_PostC.png", "MadhavRamesh_Post", "C")

iCe_demo("MadhavRamesh_PreT.csv", "MadhavRamesh_PostT.csv", "MadhavRamesh_test")
iCe_demo("MadhavRamesh_PreC.csv", "MadhavRamesh_PostC.csv", "MadhavRamesh_control")



