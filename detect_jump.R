library(reshape2)
library(ggplot2)
library(dplyr)

library(qpcR)

cyc <- reps[, 1]
y <- reps[, 11]


#The start of the exponential phase is defined by a jump: when fluorescence in cycle C+1 is less 
#than the fluorescence in cycle C then the exponential phase starts at cycle c
bot <- c(NA, sapply(2L:length(y), function(i) y[i] - y[i - 1])) < 0
top <- c(NA, sapply(2L:length(y), function(i) y[i - 1] - y[i])) < 0
#Linreg: all samples excluded
#does linreg estimate eff without baselining?

data.frame(cyc, y, bot, top) %>% melt(id.vars = "cyc") %>%
  ggplot(aes(x = cyc, y = value, colour = variable)) +
  geom_point(size = 3) +
  facet_wrap(~ variable, ncol = 1)

#reps 11 - check it using linreg. no visible jump
