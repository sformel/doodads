#https://www.idtdna.com/pages/education/decoded/article/4-tips-for-accurate-oligonucleotide-quantification-using-thermo-scientific-nanodrop-instruments

#We measured A260 on the nanodrop, which you can then use to calculate concentration from Bie Lamberts Law
#exctinction coefficient is on packing sheet

#should have turned off 340nm correction, need to remeasure.

# Bier Lambert's Law

#Absorbance = molar attenuation coefficient x path length x concentration

#LR3 @ 10uM (Callie's pooled primers)

A <- 1.536
E <- 161300
b <- 1 # or 0.2, need to remeasure and recalculate
c #what we want to know

A/(E*b)

# conc = 9.522629 uM

#ITS1F @ 10um

A <- 2.052
E <- 225300
b <- 1

A/(E*b)

#conc = 9.107856 uM

#1492R @ 10uM

A <- 1.913
E <- 175200
b <- 1

A/(E*b)

#conc = 10.91895 uM

#27F @ 10uM

A <- 1.971
E <- 195200
b <- 1

A/(E*b)

#conc = 10.09734 uM

#LR3 @ 100uM

A <- 17.541
E <- 161300
b <- 1

A/(E*b)

#conc = 108.7477 uM



