y <- reps[, 2]
# 'Set baseline to minimum observation'
bl <- min(y)
#Q1 Does apply baseline mean substract baseline? 
#y after baselining
ybl <- y - bl
# 'Samples are skipped when less than seven times 
# increase in fluorescence values is observed.'
#Q2 After baselining minimum value is 0. We need to 
#compare highest value and second lowest value
if(max(ybl)/min(ybl[ybl != 0]) > 7) {
  # 'Determine SDM cycle'
  ders <- summary(inder(1L:length(ybl), ybl, smooth.method = NULL), 
                  print = FALSE)
  # 'For each sample that shows amplification, an iterative 
  # algorithm than repeatedly adjusts the baseline value until 
  # the slope of the regression line through the data points in
  # the upper half of the exponential phase differs less than 0.0001 
  # from the slope of the line through the data points in the lower half.'
  
  #Q3 How to define lower and upper border of exponential phase?
  exp_start <- trunc(ders[["SDM"]] - 1.3 * (ders[["SDm"]] - ders[["SDM"]]), 0)
  exp_end <- trunc(ders[["SDm"]] + 1.3 * (ders[["SDm"]] - ders[["SDM"]]), 0)
  SDM <- trunc(ders[["SDM"]], 0)
  
  # 'Compare S_upper and S_lower'
  #Q4 Does regressions involve also SDM cycle?
  
  #
  id_lower <- exp_start:SDM
  s_lower <- coef(lm(ybl[id_lower] ~ id_lower))[2]
  
  id_upper <- SDM:exp_end
  s_upper <- coef(lm(ybl[id_upper] ~ id_upper))[2]
  
  if(s_upper < s_lower) {
    # 'decrease baseline by 1%'
    #Q5 what to do if baseline is negative? should I substract 0.01 from the
    #baseline or calculate 0.99 of already negative baseline? Substracting seems
    #not valid, because starting baseline is equal to the minimum observation
    #and substracting woul cause a baseline error.
    bl <- bl * 0.99
    ybl <- y - bl
  } else {
    step <- 0.005 * bl
  }
    
}
