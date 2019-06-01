#Make a distance matrix out of a matrix of Latitutde and longitude coordiantes

#load geosphere package to make distance matrix
library(geosphere)

#Here are some important notes about formatting your GPS coordinates from the geosphere package pdf:

    #1. Geographic locations must be specified in longitude and latitude (and in that order!) in degrees (i.e., NOT in radians). Degrees need to be in decimal notation. 
    
    #2. Thus 12 degrees, 10 minutes, 30 seconds = 12 + 10/60 + 30/3600 =  12.175 degrees. 
    
    #3. The southern and western hemispheres have a negative sign.
    
    #4. The default unit of distance in the output is meter.


#I've included an example of a GPS matrix.

#set working directory
setwd("C:/Users/Stephen and Moppa/Google Drive/Van Bael Google Drive/Boggs443 Data & User folders/Users/Grad Students/Steve/")

#load in GPS matrix

GPS.matrix <- read.csv("example_GPS_matrix.csv")

#convert long and lat into a two column matrix
GPS.matrix.columns <- as.matrix(GPS.matrix[,c("longitude","latitude")])

#view matrix
GPS.matrix.columns

#make distance matrix using Vincenty Ellipsoid method.

dist.matrix <- distm(GPS.matrix.columns, GPS.matrix.columns, fun = distVincentyEllipsoid)

#add sample names back into matrix
dist.matrix <- as.data.frame(dist.matrix)
colnames(dist.matrix) <- GPS.matrix$sampleID
row.names(dist.matrix) <- GPS.matrix$sampleID

#check that names are right
dist.matrix

#REALLY IMPORTANT!
#When you do tha mantel test, make sure your samples are in the same order on your community distance matrix and your geographic distance matrix.  The easiest way to do this is to make sure the longitude and latitude are listed in the same order as your community marix, before you run the commands above.