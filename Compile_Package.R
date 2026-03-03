install.packages("usethis")
install.packages("roxygen2")
install.packages("devtools")
library(roxygen2)
library(usethis)
library(devtools)

###Create Directory for Package Creation###
create_package("/Users/jamesgow/Desktop/aCePrep2.0.1") #do not re-run, creates a directory for package contents

setwd("/Users/jamesgow/Desktop/aCePrep2.0.1")

devtools::document() #This creates .Rd files in the man/ directory and updates the NAMESPACE file.
devtools::build() #compile package
devtools::test("/Users/jamesgow/Desktop/aCePrep2.0.1") #use the testdata in inst/ and the file in tests to check functions are working

