# aCePrep News

## 2.0.1
- Renamed package to aCe
- Added aCe calculation
- Designed Shiny app

## 1.2.1
- Added back the y axis with relative graphical units to ClientGraph

## 1.1.1
- Changed the automated adjustment of minima and maxima for ClientGraph to assess both the max value for the Pre and Post graphs

## 1.0.9
- Automated the adjustment of minima and maxima for ClientGraph
- Bug fixed in inflecpoints commands

## 1.0.8
- Allow for manual adjustment of minima and maxima for ClientGraph

## 1.0.7
- Added new function to process images (PNG) into datatables for use in aCe_demo

## 1.0.6
- Added ggplot overlay for external viewership
- Combined Pre and Post exercise into single function

## 1.0.5
- Adjusted inflection point code to capture maxima and minima to handle Pre exercise dataset
- Removed the rounding filtering of localMaxima
- Looped the filtering by differential to improve removal of clustered inaccurate EndoPat readings
- Dropped legacy graphs
- Added manual check graphs in the local

## 1.0.4
- Adjusted code for new EndoPAT data extraction
- Removed cleaning filter to reduce influence of aberrant readings

## 1.0.3
- Replaced legacy plots with ggplot graphs

## 1.0.2
- Replaced awk command line call with the base R distinct function
