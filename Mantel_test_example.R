#How to run a mantel test on a community matrix and a geographical matrix
#By Steve Formel
#Last updated June 25, 2019

#load libraries-----
library(vegan)
library(geosphere)

#Notes------
  
#REALLY IMPORTANT!
#When you do tha mantel test, make sure your samples are in the same order on your community distance matrix and your geographic distance matrix.  The easiest way to do this is to make sure the longitude and latitude are listed in the same order as your community marix, before you run the commands below.
  
#Here are some important notes about formatting your GPS coordinates from the geosphere package pdf:

    #1. Geographic locations must be specified in longitude and latitude (and in that order!) in degrees (i.e., NOT in radians). Degrees need to be in decimal notation. 
    
    #2. Thus 12 degrees, 10 minutes, 30 seconds = 12 + 10/60 + 30/3600 =  12.175 degrees. 
    
    #3. The southern and western hemispheres have a negative sign.
    
    #4. The default unit of distance in the output is meter.

#Make sample GPS (geographical) matrix (like something you might generate from a GPS unit)----

GPS.matrix <- data.frame("sampleID" = c("sample1", "sample2", "sample3", "sample4"), 
                         "longitude" = c(-90.145345, -90.145354, -90.145335, -90.145346),
                         "latitude" = c(29.133361, 29.133472, 29.133364, 29.133392))

#assuming you read your data in as a csv, you need to convert it to a matrix.
#convert long and lat into a two column matrix
GPS.matrix.columns <- as.matrix(GPS.matrix[,c("longitude","latitude")])

#view matrix
GPS.matrix.columns

#make distance matrix using Vincenty Ellipsoid method.
dist.matrix <- distm(GPS.matrix.columns, GPS.matrix.columns, fun = distVincentyEllipsoid)

#Make sample communityu matrix----
#note that vegan assumes samples are rows and taxa are columns

comm.matrix <- data.frame(row.names = GPS.matrix$sampleID,
                          "T1" = abs(rnorm(n =4)),
                          "T2" = abs(rnorm(n =4)),
                          "T3" = abs(rnorm(n =4)),
                          "T4" = abs(rnorm(n =4)))
  
#make bray-curtis dissimilarity matrix
comm.dist <- vegdist(comm.matrix, method = "bray")

#Run mantel test-----

#Pearson's Correlation (not ranked)
mantel(comm.dist, dist.matrix, method = "pearson")

#Spearman's Correlation (ranked)
mantel(comm.dist, dist.matrix, method = "spearman")

#if you're curious about how to interpret output, read the help file
?mantel

