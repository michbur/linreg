#' Get slopes of regression lines in exponential phase
#' 
#' Computes slopes regression line through the data points in the upper and lower half of 
#' the exponential phase.
#' 
#' @aliases exp_slopes
#' @param fluorescence values.
#' @return 
#' @author Michal Burdukiewicz.
#' @keywords manip
#' @export
#' @examples
#' library(qpcR)
#' exp_slopes(reps[, 2])

exp_slopes <- function(y, fluo_log = FALSE) {
  # 'Determine SDM cycle'
  ders <- summary(inder(1L:length(y), y, smooth.method = NULL), 
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
  id_lower <- exp_start:SDM 
  id_upper <- (SDM + 1):exp_end
  if(fluo_log) 
    y <- log10(y)
  
  lower <- lm(y[id_lower] ~ id_lower)
  upper <- lm(y[id_upper] ~ id_upper)
  
  lower <- lm(y[id_lower] ~ id_lower)
  upper <- lm(y[id_upper]~ id_upper)
  list(slopes = c(lower = as.vector(coef(lower)[2]), 
                  upper = as.vector(coef(upper))[2]),
       models = list(lower = lower,
                     upper = upper),
       fluo = y,
       borders = c(exp_start, SDM, exp_end))
}

plot.slopes <- function(x, fluo_log = FALSE) {
  fluo <- x[["fluo"]]
  plot(fluo, xlab = "Cycle", ylab = "Fluorescence")
  abline(x[["models"]][["upper"]], col = "red")
  points((x[["borders"]][2] + 1):x[["borders"]][3], 
         fluo[(x[["borders"]][2] + 1):x[["borders"]][3]],
         col = "red", pch = 19)
  
  abline(x[["models"]][["lower"]], col = "blue")
  points(x[["borders"]][1]:x[["borders"]][2], 
         fluo[x[["borders"]][1]:x[["borders"]][2]],
         col = "blue", pch = 19)
}


tmp <- exp_slopes(reps[, 2] + 1, fluo_log = TRUE)
plot.slopes(tmp, fluo_log = TRUE)




# Part 0 ------------------------------------
y <- reps[, 4]
# 'Set baseline to minimum observation'
bl <- min(y)
#Q1 Does apply baseline mean substract baseline? 
#y after baselining
ybl <- y - bl
# 'Samples are skipped when less than seven times 
# increase in fluorescence values is observed.'
#Q2 After baselining minimum value is 0. We need to 
#compare highest value and second lowest value
#if(max(ybl)/min(ybl[ybl != 0]) > 7) {
# Part I ------------------------------------
#slope lower and upper
#QX Should data be exponential?
slu <- exp_slopes(ybl, fluo_log = TRUE)[["slopes"]]

while(slu["upper"] < slu["lower"]) {
  # 'decrease baseline by 1%'
  #Q5 what to do if baseline is negative? should I substract 0.01 from the
  #baseline or calculate 0.99 of already negative baseline? Substracting seems
  #not valid, because starting baseline is equal to the minimum observation
  #and substracting woul cause a baseline error.
  bl <- bl * 0.99
  slu <- exp_slopes(y - bl, fluo_log = TRUE)[["slopes"]]
  print(slu)
}

#when while loop ends, we know that slu["upper"] > slu["lower"]
stp <- 0.005 * bl

# Part II ------------------------------------
#Q6 What if step is negative?
bl <- bl + stp
ybl <- y - bl

#while(abs(slu["upper"] - slu["lower"]) > 1e-5) {
for(sth in 1L:100) {
  if(slu["upper"] < slu["lower"]) {
    #Q7 what means - 2.step
    bl <- bl - 2*stp
    stp <- stp/2
    slu <- exp_slopes(y - bl)[["slopes"]]
    print("A")
  } else {
    bl <- bl + stp
    slu <- exp_slopes(y - bl)[["slopes"]]
  }
  print(abs(slu["upper"] - slu["lower"]))
}




