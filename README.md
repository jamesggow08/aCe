# iCe

Purpose: Prepare Blood Pressure Data for iCe -- Extracts Pulse Wave information from EndoPAT derived PDF to calculate initial linear slope of pulse wave rise in response to hypoxemia.
Current Version: 1.0.7
Dependencies: data.table, dplyr, ggplot2, ggpubr, grid, Hmisc, png, raster
Author: James Gow
License: MIT + file LICENSE
Encoding: UTF-8
Version History:
1.0.2 -- i) replace awk command line call with the baseR distinct function
1.0.3 -- i) replace legacy plots with ggplot graph
1.0.4 -- i) adjust code for new EndoPAT data extraction and remove cleaning filter to reduce influence of aberrant readings
1.0.5 -- i) asjust inflection point code to capture maxima and minima too to adjust for Pre exercise dataset; 
         ii) remove the rounding filtering of localMaxima;
         iii) looped the filtering by differential to improve removal of clustered inaccurate EndoPat readings;
         iv) dropped legacy graphs; and
         v) added manula check graphs in the local
1.0.6 -- i) add ggplot overlay for external viewship; and
         ii) combine Pre and Post exercise into single function
1.0.7 -- i) add in new function to process images (png) into datatables for use in iCe_demo

Execution Sample: setwd("/Users/jamesgow/Desktop/test")
                  Image_Process("post.png", "AndrewGow_Post", "T")
                  Image_Process("pre.png", "AndrewGow_Pre", "T")
                  iCe_demo("AndrewGow_PreT.csv", "AndrewGow_PostT.csv", "AndrewGow")
