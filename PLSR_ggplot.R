#Make a ggplot object for a Partial Least Squares Regression (PLSR) plot so it can be easily manipulated and arranged with other figures for a manuscript.

#####################################################
## Note that this code may break as ggplot updates,##
## as is noted on some of the below posts.         ##
#####################################################

#Put together by Steve Formel - thought mostly taken from the below messageboards.
#Last updated June 24, 2019

#Links to posts-------------

#https://stackoverflow.com/questions/48664746/how-to-set-two-x-axis-and-two-y-axis-using-ggplot2

#https://stackoverflow.com/questions/39137287/plotting-partial-least-squares-regression-plsr-biplot-with-ggplot2

#https://www.stat.auckland.ac.nz/~paul/useR2015-grid/grid-slides.html

#https://stackoverflow.com/questions/21026598/ggplot2-adding-secondary-transformed-x-axis-on-top-of-plot

#https://stackoverflow.com/questions/36754891/ggplot2-adding-secondary-y-axis-on-top-of-a-plot/36759348#36759348


#load libraries------
library(pls) #version 2.7.1
library(ggplot2) #version 3.1.0
library(grid) #version 3.5.1
library(gtable) #version 0.2.0
library(cowplot) #version 0.9.3
library(ggplotify) #version 0.0.3

#Read data into PLSR model-----
dens1 <- plsr(density ~ NIR, ncomp = 5, data = yarn)

#Extract information from plsr (AKA mvr) model----
df1<-as.data.frame(dens1$loadings[,1:2])
names(df1) <- c("comp1", "comp2")

df2<-as.data.frame(dens1$scores[,1:2])
names(df2) <- c("comp1a", "comp2a")

#make ggplot objects------

#Plot Loadings - colored red

p1 <- ggplot(data=df1, 
           aes(x = comp1, y = comp2)) +
  geom_text(aes(label = rownames(df1)), 
            color="red") +
  theme_bw() + 
  theme(panel.border = element_rect(colour = "black", 
                                    fill=NA, 
                                    size=1),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black"),
        axis.ticks = element_line(colour = "red"),
        axis.text.y = element_text(margin = margin(10,10,10,5,"pt"), 
                                   angle = 90, 
                                   hjust = 0.65, 
                                   colour = "red"),
        axis.text.x = element_text(colour = "red")) +
  scale_y_continuous(limits = c(min(df1), max(df1))) +
  scale_x_continuous(limits = c(min(df1), max(df1)))



#Plot 2 - scores in black
p2 <- ggplot(data=df2, 
             aes(x = comp1a, y = comp2a)) +
  geom_text(aes(label = rownames(df2)), 
            color="black") +
  theme_bw() + 
  theme(panel.border = element_rect(colour = "black", 
                                    fill=NA, 
                                    size=1),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black"),
        axis.ticks = element_line(colour = "black"),
        axis.text.y = element_text(margin = margin(10,10,10,5,"pt"), 
                                   angle = 90, 
                                   hjust = 0.65, 
                                   colour = "black"),
        axis.text.x = element_text(colour = "black")) +
  scale_y_continuous(limits = c(min(df2), max(df2))) +
  scale_x_continuous(limits = c(min(df2), max(df2)))

#Final plot----

#Overlay plots in order to get two graphs with different axes on same plot
#rename plots in case you want to make adjustments without regenerating plots

plot1 <- p1
plot2 <- p2
  
# Update plot with transparent panel
plot2 = plot2 + 
    theme(panel.background = element_rect(fill = "transparent")) 
  
#clean plot space
grid.newpage()
  
# Extract gtables from ggplot objects
g1 = ggplot_gtable(ggplot_build(plot1))
g2 = ggplot_gtable(ggplot_build(plot2))
  
# Get the location of the plot panel in g1.
# These are used later when transformed elements of g2 are put back into g1

pp <- c(subset(g1$layout, name == "panel", se = t:r))
  
# Overlap panel for second plot on that of the first plot

g1 <- gtable_add_grob(g1, g2$grobs[[which(g2$layout$name == "panel")]], pp$t, pp$l, pp$b, pp$l)

#Note from stack overflow post:  
# Get the location of the plot panel in g1.
# These are used later when transformed elements of g2 are put back into g1
pp <- c(subset(g1$layout, name == "panel", se = t:r))

# Overlap panel for second plot on that of the first plot
g1 <- gtable_add_grob(g1, g2$grobs[[which(g2$layout$name == "panel")]], pp$t, pp$l, pp$b, pp$l)

# Then proceed as before:

# ggplot contains many labels that are themselves complex grob; 
# usually a text grob surrounded by margins.
# When moving the grobs from, say, the left to the right of a plot,
# Make sure the margins and the justifications are swapped around.
# The function below does the swapping.
# Taken from the cowplot package:
# https://github.com/wilkelab/cowplot/blob/master/R/switch_axis.R 

hinvert_title_grob <- function(grob){
  
  # Swap the widths
  widths <- grob$widths
  grob$widths[1] <- widths[3]
  grob$widths[3] <- widths[1]
  grob$vp[[1]]$layout$widths[1] <- widths[3]
  grob$vp[[1]]$layout$widths[3] <- widths[1]
  
  # Fix the justification
  grob$children[[1]]$hjust <- 1 - grob$children[[1]]$hjust 
  grob$children[[1]]$vjust <- 1 - grob$children[[1]]$vjust 
  grob$children[[1]]$x <- unit(1, "npc") - grob$children[[1]]$x
  grob
}

# Get the y axis title from g2

# Which grob contains the y axis title?
index <- which(g2$layout$name == "ylab-l") 

# Extract that grob
ylab <- g2$grobs[[index]]                

# Swap margins and fix justifications
ylab <- hinvert_title_grob(ylab)         

# Put the transformed label on the right side of g1
g1 <- gtable_add_cols(g1, g2$widths[g2$layout[index, ]$l], pp$r)
g1 <- gtable_add_grob(g1, ylab, pp$t, pp$r + 1, pp$b, pp$r + 1, clip = "off", name = "ylab-r")
  
# Get the y axis from g2 (axis line, tick marks, and tick mark labels)

# Which grob
index <- which(g2$layout$name == "axis-l")  

# Extract the grob
yaxis <- g2$grobs[[index]]                  
  
# yaxis is a complex of grobs containing the axis line, the tick marks, and the tick mark labels.
# The relevant grobs are contained in axis$children:
#   axis$children[[1]] contains the axis line;
#   axis$children[[2]] contains the tick marks and tick mark labels.
  
# First, move the axis line to the left
yaxis$children[[1]]$x <- unit.c(unit(0, "npc"), unit(0, "npc"))
  
# Second, swap tick marks and tick mark labels
ticks <- yaxis$children[[2]]
ticks$widths <- rev(ticks$widths)
ticks$grobs <- rev(ticks$grobs)
  
# Third, move the tick marks
ticks$grobs[[1]]$x <- ticks$grobs[[1]]$x - unit(1, "npc") + unit(1, "mm")
  
# Fourth, swap margins and fix justifications for the tick mark labels
ticks$grobs[[2]] <- hinvert_title_grob(ticks$grobs[[2]])
  
# Fifth, put ticks back into yaxis
yaxis$children[[2]] <- ticks
  
# Put the transformed yaxis on the right side of g1
g1 <- gtable_add_cols(g1, g2$widths[g2$layout[index, ]$l], pp$r)
g1 <- gtable_add_grob(g1, yaxis, pp$t, pp$r + 1, pp$b, pp$r + 1, clip = "off", name = "axis-r")
  
#Draw it for a dummy check
  
grid.newpage()
grid.draw(g1)
  
# function that can vertically invert a title grob, with margins treated properly
# title grobs are used a lot in the new ggplot2 version (>1.0.1)
vinvert_title_grob <- function(grob) {
  heights <- grob$heights
  grob$heights[1] <- heights[3]
  grob$heights[3] <- heights[1]
  grob$vp[[1]]$layout$heights[1] <- heights[3]
  grob$vp[[1]]$layout$heights[3] <- heights[1]
  
  grob$children[[1]]$hjust <- 1 - grob$children[[1]]$hjust
  grob$children[[1]]$vjust <- 1 - grob$children[[1]]$vjust
  grob$children[[1]]$y <- unit(1, "npc") - grob$children[[1]]$y
  grob
  }
  
# Copy title xlab from g2 and swap margins
index <- which(g2$layout$name == "xlab-b")
xlab <- g2$grobs[[index]]
xlab <- vinvert_title_grob(xlab)

# Put xlab at the top of g1
g1 <- gtable_add_rows(g1, g2$heights[g2$layout[index, ]$t], pp$t-1)
g1 <- gtable_add_grob(g1, xlab, pp$t, pp$l, pp$t, pp$r, clip = "off", name="xlab-t")
  
# Get "feet" axis (axis line, tick marks and tick mark labels) from g2
index <- which(g2$layout$name == "axis-b")
xaxis <- g2$grobs[[index]]
  
# Move the axis line to the bottom (Not needed in your example)
xaxis$children[[1]]$y <- unit.c(unit(0, "npc"), unit(0, "npc"))
  
# Swap axis ticks and tick mark labels
ticks <- xaxis$children[[2]]
ticks$heights <- rev(ticks$heights)
ticks$grobs <- rev(ticks$grobs)
  
# Move tick marks
ticks$grobs[[2]]$y <- ticks$grobs[[2]]$y - unit(1, "npc") + unit(3, "pt")
  
# Swap tick mark labels' margins
ticks$grobs[[1]] <- vinvert_title_grob(ticks$grobs[[1]])
  
# Put ticks and tick mark labels back into xaxis
xaxis$children[[2]] <- ticks
  
# Add axis to top of g1
g1 <- gtable_add_rows(g1, g2$heights[g2$layout[index, ]$t], pp$t)
g1 <- gtable_add_grob(g1, xaxis, pp$t+1, pp$l, pp$t+1, pp$r, clip = "off", name = "axis-t")
  
#remove title and axes titles if necessary
g1 <- gtable_remove_grobs(g1, c("title", "xlab-t", "xlab-b", "ylab-r", "ylab-l"))
  
# Draw it
grid.newpage()
my_PLS = ggplotify::as.ggplot(g1)

#save plot in square format----
ggsave(paste0("my_PLS_",Sys.Date(),".png"), width = 6, height = 6, units = "in", plot = my_PLS)
  