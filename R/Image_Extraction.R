#' Image Extraction
#' Takes in a png image of a line graph (which is ostensibly a screenshot of EndoPat) and identifies all the pixels which are associated with a line on the line graph
#'
#' @param x "screenshot.png"
#' @param y "Name_ExerciseStatus"
#' @param z "Treatment"
#'
#' @return Person_ExerciseStatus_TrtGroup.csv
#'
#' @importFrom raster raster
#' @importMethodsFrom raster as.data.frame
#' @importMethodsFrom raster plot
#' @importFrom data.table as.data.table
#'
#' @export Image_Process
#'
#' @examples Image_Process("patient.png", "AndrewGow_Pre", "T")
Image_Process <- function(x, y, z) {
  name2 <- paste0(y, z, ".csv")

  img <- raster(x)
  #ext <- extent(0, 350, 0, 400) -- may be used in future to adjust issues with screenshotting size
  #extent(img) <- ext
  #print(extent(img))

  df <- as.data.frame(img, xy = TRUE)
  plot(img)

  dt <- as.data.table(df)
  subset_dt <- dt[which(dt[, 3] == 0), ]
  data <- subset_dt[, c("x", "y")]
  write.table(data, file = name2, row.names=F, col.names=F, sep=",")
  }
