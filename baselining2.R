is_amplified <- function(fluo) {
  max(fluo)/min(fluo) > 7
}

simple_derivation <- function(y)
  c(NA, sapply(2L:length(y), function(i) y[i] - y[i - 1]))

get_jump <- function(y)
  simple_derivation(y) < 0

#get exponential phase indices
get_exp <- function(y) {
  #exponential phase ends with SDM
  SDM_id <- which.max(simple_derivation(simple_derivation(y)))
  #exponential phase starts which a jump
  jump_id <- SDM_id - which.max(simple_derivation(y[1L:SDM_id]) < 0)
  c(start = jump_id + 1, end = SDM_id)
}

#get single slope
get_slope <- function(y)
  coef(lm(y ~ x, data = data.frame(x = (1L:length(y)), y = log(y))))[["x"]]

#get both slopes
get_slopes <- function(y) {
  exp_borders <- get_exp(y)
  #exponential phase
  expp <- y[exp_borders["start"]:exp_borders["end"]]
  lexpp <- length(expp)
  
  #range of regions
  if(lexpp %% 2 == 0) {
    #exponential phase bottom
    exppl <- expp[1L:(lexpp/2)]
    #exponential phase upper
    exppu <- expp[(lexpp/2 + 1):lexpp]
  } else {
    #exponential phase bottom
    exppl <- expp[1L:(lexpp/2)]
    #exponential phase upper
    exppu <- expp[(lexpp/2):lexpp]
  }
  
  c(l = get_slope(abs(exppl)), u = get_slope(abs(exppu)))
}


library(qpcR)

# baselining function --------------------------------------------

baseline <- function(fluo, max_it = 100) {
  
  #if sample is not amplified, end function
  is_amplified(fluo)
  
  
  #preserve raw input
  raw_fluo <- fluo
  
  bl <- min(fluo)
  fluo <- fluo - bl
  #if min(data) is 0, we need to add small epsilon, because linreg 
  #often uses proportion of minimum and maximum value
  if(bl == 0) {
    fluo <- fluo + 0.001*max(fluo)
    bl <- min(fluo)
  }
  
  
  #Part 1 ---------------------------
  
  
  #new baseline: mean of 6th and 7th point before the plateau phase
  bl <- mean(fluo[(which.min(simple_derivation(simple_derivation(fluo)))-2:1)])
  fluo <- fluo - bl
  sl <- get_slopes(fluo)
  
  it <- 0
  while(sl["u"] <  sl["l"]  && it < max_it) {
    bl <- bl * 0.99
    
    #add here if statement
    bl < min(fluo)
    
    
    fluo <- fluo - bl
    
    sl <- get_slopes(fluo)
    it <- it + 1
  }
  
  stp <- 0.005*bl 
  
  # Part 2 ---------------------------------
  
  bl <- bl + stp
  fluo <- fluo - bl
  
  sl <- get_slopes(fluo)
  
  max_it = 50
  
  it <- 0
  
  sl2 <- matrix(sl, ncol = 2)
  while(abs(sl["u"] -  sl["l"]) > 1e-5  && it < max_it) {
    if(sl["u"] < sl["l"]) {
      bl <- bl - 2*stp
      stp <- stp/2
      
      fluo <- fluo - bl
      
      sl <- get_slopes(fluo)
      
      sl2 <- rbind(sl2, sl)
      
      it <- it + 1
      
    } else {
      bl <- bl + stp
      fluo <- fluo - bl
      
      sl <- get_slopes(fluo)
      
      sl2 <- rbind(sl2, sl)
      
      it <- it + 1
    }
  }

  
  list(bl, sl2)
}


tmp <- baseline(rutledge[, 4])
