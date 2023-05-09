#' Takes data extracted from EndoPAT graph to determine inputs for iCe for the pre exercise data
#'
#'
#' @param x dataset created by the EndoPAT graph
#' @param y string used to name the outputs
#'
#' @return .csv file of inflection points (minima in first derivative)
#' @return .text file with description of linear regression of first portion of pulse pressure graph
#'
#' @return PulseWave.png of Pulse pressure graph
#' @return FirstDev.png of Pulse pressure graph first derivative
#' @return InitialSlope.png of Initial linear portion of the pulse pressure graph
#' @export
#'
#' @import data.table
#'
#' @examples iCe_pre("data.csv", "test")
iCe_pre <- function(x, y) {
  name <- paste0(y, "_Pre")
  read_data(x)
  print ("Data Read Success")
  calcLocalMax(data2)
  print ("Max Values Calculated")
  calcLocalMin(data2)
  print ("Min Values Calculated")
  localvalremoveMax(MaximaRows)
  print ("Max Values Cleaned")
  localvalremoveMin(MinimaRows)
  print ("Min Values Cleaned")
  nonparam(FinalMaxima4, FinalMinima4, name)
  firstdev(predpulsewave, name)
  print ("Graphing Done")
  initialslope(predpulsewave, name)
  print ("Slope Calculated")
  inflecpoints(dapulsewave)
  name <- paste0("inflectionpoints", y, "_Pre.csv")
  inflection_points2 <- inflection_points[, c(1, 2, 3, 4)]
  inflection_points3 <- inflection_points2 %>% arrange(Relative_time)
  inflection_points3$Corrected_time <- inflection_points3$Relative_time/2.16
  write.table(inflection_points3, file=name, sep=",", row.names = FALSE)
  print ("Inflection Points Found")
  name <- paste0(y, "_Pre")
  iCegraph(x = predpulsewave, n=name)
  print ("New Graph Added")
}

#' Takes data extracted from EndoPAT graph to determine inputs for iCe for the pre exercise data
#'
#'
#' @param x dataset created by the EndoPAT graph
#' @param y string used to name the outputs
#'
#' @return .csv file of inflection points (minima in first derivative)
#' @return .text file with description of linear regression of first portion of pulse pressure graph
#'
#' @return PulseWave.png of Pulse pressure graph
#' @return FirstDev.png of Pulse pressure graph first derivative
#' @return InitialSlope.png of Initial linear portion of the pulse pressure graph
#' @export
#'
#' @examples iCe_demo("data.csv", "test")
iCe_post <- function(x, y) {
  name <- paste0(y, "_Post")
  read_data(x)
  print ("Data Read Success")
  calcLocalMax(data2)
  print ("Max Values Calculated")
  calcLocalMin(data2)
  print ("Min Values Calculated")
  localvalremoveMax(MaximaRows)
  print ("Max Values Cleaned")
  localvalremoveMin(MinimaRows)
  print ("Min Values Cleaned")
  nonparam(FinalMaxima4, FinalMinima4, name)
  firstdev(predpulsewave, name)
  print ("Graphing Done")
  initialslope(predpulsewave, name)
  print ("Slope Calculated")
  inflecpoints(dapulsewave)
  name <- paste0("inflectionpoints", y, "_Post.csv")
  inflection_points2 <- inflection_points[, c(1, 2, 3, 4)]
  inflection_points3 <- inflection_points2 %>% arrange(Relative_time)
  inflection_points3$Corrected_time <- inflection_points3$Relative_time/2.16
  write.table(inflection_points3, file=name, sep=",", row.names = FALSE)
  print ("Inflection Points Found")
  name <- paste0(y, "_Post")
  iCegraph(x = predpulsewave, n=name)
  print ("New Graph Added")
}

#' Runs pre are post exercise iCe functions and prepares output overlay graph
#'
#' @param x pre exercise dataset created by the EndoPAT graph
#' @param y post exercise dataset created by the EndoPAT graph
#' @param n string used to name the outputs
#'
#' @return .csv files of inflection points (minima in first derivative)
#' @return .text files with description of linear regression of first portion of pulse pressure graph
#'
#' @return PulseWave.png of Pulse pressure graph
#' @return FirstDev.png of Pulse pressure graph first derivative
#' @return InitialSlope.png of Initial linear portion of the pulse pressure graph
#' @export iCe_demo
#'
#' @examples iCe_demo("data_PreT.csv", "data_PostT.csv", "Patient_name")
iCe_demo <- function(x, y, n) {
  m <<- "Pre"
  iCe_pre(x, n)
  m <<- "Post"
  iCe_post(y, n)
  Clientgraph(Pre, Post, n)

  #Clean Up
  #rm(data2, envir = .GlobalEnv)
  #rm(FinalMaxima4, envir = .GlobalEnv)
  #rm(FinalMinima4, envir = .GlobalEnv)
  #rm(MaximaRows, envir = .GlobalEnv)
  #rm(MinimaRows, envir = .GlobalEnv)
  #rm(predpulsewave, envir = .GlobalEnv)
  #rm(dapulsewave, envir = .GlobalEnv)
  #rm(inflection_points, envir = .GlobalEnv)
  #rm(m, envir = .GlobalEnv)
  #rm(newvals2, envir = .GlobalEnv)
  #rm(Pre, envir = .GlobalEnv)
  #rm(Post, envir = .GlobalEnv)
}


