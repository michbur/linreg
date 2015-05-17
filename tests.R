library(qpcR)
library(chipPCR)
source("baselining.R")
baseline(fluo = reps[, 28])

#threshold log(fluo) 0.113
#eff 1,831
#R^2 0.99999
#cycles 11-15 - linear


#look for jumps
lapply(2L:ncol(reps), function(i) {
  ders <- summary(inder(reps[, 1], reps[, i], smooth.method = NULL),  print = FALSE)
  exp_end <- round(ders[["SDM"]], 0)
  
  sapply(exp_end:2, function(fluo_id) (reps[fluo_id, i] - reps[fluo_id - 1, i])) 
})


