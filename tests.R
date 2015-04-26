library(qpcR)
library(chipPCR)
source("baselining.R")
baseline(fluo = reps[, 2])

#threshold log(fluo) 0.113
#eff 1,831
#R^2 0.99999
#cycles 11-15 - linear
