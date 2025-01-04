# iCe

Purpose: Prepare Blood Pressure Data for iCe -- Extracts Pulse Wave information from EndoPAT derived PDF to calculate initial linear slope of pulse wave rise in response to hypoxemia.

Current Version: 1.2.1

Dependencies: data.table, dplyr, ggplot2, ggpubr, grid, Hmisc, png, raster

Author: James Gow

Execution Sample:
setwd("/Users/jamesgow/Desktop/ice_test")
Image_Process("MadhavRamesh_PreT.png", "MadhavRamesh_Pre", "T")
Image_Process("MadhavRamesh_PostT.png", "MadhavRamesh_Post", "T")
Image_Process("MadhavRamesh_PreC.png", "MadhavRamesh_Pre", "C")
Image_Process("MadhavRamesh_PostC.png", "MadhavRamesh_Post", "C")

iCe_demo("MadhavRamesh_PreT.csv", "MadhavRamesh_PostT.csv", "MadhavRamesh_test")
iCe_demo("MadhavRamesh_PreC.csv", "MadhavRamesh_PostC.csv", "MadhavRamesh_control")
