#Script to run an adonis test AKA PERMANOVA.  PERMANOVA is the proprietary PRIMER test.  Adonis is the vegan version of the test.  As far as I understand it, the two tests are more or less the same, although adonis returns an R^2 value as well

#there are actually two functions:  "adonis" and "adonis2".  Search the Rhelp by typing "?adonis" to read about the differences.  I think for our purposes "adonis" is good enough.

setwd("C:/Users/Stephen and Moppa/Google Drive/Van Bael Google Drive/Boggs443 Data & User folders/Users/Grad Students/Steve/")

library(vegan)

#load data-----------------
#load community matrix
data(dune) #this is how you load the practice vegan data, your community matrix must be imported as a data frame.

#example of importing community matrix as a data frame, do the same for your table of explanatory variables
com.matrix <- read.csv("dummy_com_matrix.csv")

#load environmental variables/explanatory variables from vegan practice data
data(dune.env)

#run adonis---------------
#create dis/similarity matrix
dis.matrix <- vegdist(dune, method = "bray")

#run adonis, creates anova table output
adonis.results <- adonis(dis.matrix ~ Management*Use, method = "bray", data = dune.env)

#view anova table
adonis.results

#So differences in Management were significant, but not Use, or the interaction of Management and Use

#run permdisp test--------------
#Perform PERMDISP - compares dispersion of samples to see if adonis results are due to different dispersion and not different community compositions...I don't fully understand this, so do some reading/asking around.

disp <- betadisper(dis.matrix, dune.env$Management)
permdisp_test<-(permutest(disp)) 

#view results
permdisp_test

#My interpretation: Since Management ("groups") was not significant, differences detected by the adonis were due to differences in community composition among the samples.  But run that by someone else...
