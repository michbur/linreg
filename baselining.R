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

exp_slopes <- function(cyc, fluo, fluo_log = FALSE) {
  # 'Determine SDM cycle'
  ders <- summary(inder(cyc, fluo, smooth.method = NULL), 
                  print = FALSE)
  # 'For each sample that shows amplification, an iterative 
  # algorithm than repeatedly adjusts the baseline value until 
  # the slope of the regression line through the data points in
  # the upper half of the exponential phase differs less than 0.0001 
  # from the slope of the line through the data points in the lower half.'
  
  log_fluo <- log10(fluo)
  
  #Q3 How to define lower and upper border of exponential phase?
  #A3: Upper is SDM
  #A3: The start of the exponential phase is defined by a jump: when fluorescence 
  #in cycle C+1 is less than the fluorescence in cycle C then the exponential 
  #phase starts at cycle c. Of course coming down from the plateau 
  #exp_start <- takeoff(pcrfit(data.frame(cyc, fluo), 1, 2, l5))[["top"]]
  exp_end <- round(ders[["SDM"]], 0)
  exp_start <- min(which(sapply(2L:exp_end, function(fluo_id) (fluo[fluo_id] - fluo[fluo_id - 1])/max(fluo)) > 0.005))

  # 'Compare S_upper and S_lower'
  #Q4 Does regressions involve also SDM cycle?
  midpoint <- round(mean(c(exp_start, exp_end))) - 1
  id_lower <- exp_start:midpoint 
  #id_upper <- (midpoint + 1):exp_end
  id_upper <- midpoint:exp_end
  
  lower <- lm(log_fluo[id_lower] ~ id_lower)
  upper <- lm(log_fluo[id_upper] ~ id_upper)

  list(slopes = c(lower = as.vector(coef(lower)[2]), 
                  upper = as.vector(coef(upper))[2]),
       models = list(lower = lower,
                     upper = upper),
       log_fluo = log_fluo,
       borders = c(exp_start, midpoint, exp_end))
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


# tmp <- exp_slopes(reps[, 2] + 1, fluo_log = TRUE)
# plot.slopes(tmp, fluo_log = FALSE)


baseline <- function(cyc = 1L:length(fluo), fluo, max.it = 100) {
  # Part 0 ------------------------------------
  # 'Set baseline to minimum observation'
  bl <- min(fluo)
  #Q1 Does apply baseline mean substract baseline? 
  #y after baselining
  fluo_bl <- fluo - bl
  # 'Samples are skipped when less than seven times 
  # increase in fluorescence values is observed.'
  #Q2 After baselining minimum value is 0. We need to 
  #compare highest value and second lowest value
  #if(max(fluo_bl)/min(fluo_bl[fluo_bl != 0]) > 7) {
  # Part I ------------------------------------
  #slope lower and upper
  #"Set baseline too high"
  #"I let the algoritm start with a baseline that is too high. 
  #Because we also want three point each in teh top and the bottom 
  #part, we need six points to start with so the first baseline 
  #estimate is set to the average of the 6th and the 7th point 
  #below the plateau phase."
  
  ders <- summary(inder(cyc, fluo, smooth.method = NULL), 
                  print = FALSE)

  bl <- mean(fluo[ders[["SDm"]] - 6], fluo[ders[["SDm"]] - 7])
  fluo_bl <- fluo - bl
  
  
  #QX Should data be logarythmized? AX: Yeah, you are 
  #doing a linear regression, so you need to linearize data
  slu <- exp_slopes(cyc, fluo_bl)[["slopes"]]
  
  it <- 0
  while(slu["upper"] < slu["lower"] && it < max.it) {
    # 'decrease baseline by 1%'
    #Q5 what to do if baseline is negative? should I substract 0.01 from the
    #baseline or calculate 0.99 of already negative baseline? Substracting seems
    #not valid, because starting baseline is equal to the minimum observation
    #and substracting woul cause a baseline error.
    bl <- bl * 1.01
    slu <- exp_slopes(cyc, fluo - bl)[["slopes"]]
    it <- it + 1
  }
  
  #when while loop ends, we know that slu["upper"] > slu["lower"]
  stp <- 0.005 * bl
  
  # REMOVE ME
  cat("Finished part I. Number of iterations: ", it, "\n")
  
  # Part II ------------------------------------
  #Q6 What if step is negative?
  bl <- bl + stp
  fluo_bl <- fluo - bl
  
  it <- 0
  while(abs(slu["upper"] - slu["lower"]) > 1e-5 && it < max.it) {
    if(slu["upper"] < slu["lower"]) {
      #Q7 what means - 2.step
      bl <- bl - 2*stp
      stp <- stp/2
      slu <- exp_slopes(cyc, fluo - bl)[["slopes"]]
      it <- it + 1
      
    } else {
      bl <- bl + stp
      slu <- exp_slopes(cyc, fluo - bl)[["slopes"]]
      it <- it + 1
    }
  }
  
  # REMOVE ME
  cat("Finished part II. Number of iterations: ", it, "\n")
  
  bl
}


