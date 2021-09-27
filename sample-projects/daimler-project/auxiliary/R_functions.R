# start: start point of the grid
# end: end point of the grid

grid_finder <- function(func_dat){
  return(seq(0, 1, length.out = 100))
}

# func_dat: list that contains the observations
# each observation is a list, that conatins two vectors of identical length: args and vals
# grid: grid to use for approximation

grid_approx_set_obs <- function(func_dat, grid) {
  res_mat <- matrix(data = unlist(
      map(.x = func_dat,
          .f = function(obs) grid_approx_obs(obs$args, obs$vals, grid))
    ), nrow = length(func_dat), byrow = TRUE)
                    
  return(res_mat)
}
                    
# matr_dat: data in matrix form - each row contains the grid approximations of one observation
# fdepths: corresponding depths for the observations
# alpha: quantile of least deep observations to drop before bootstrapping
# B: number of smoothed bootstrap samples to use
# gamma: tuning parameter for smoothed bootstrap
# grid: grid used in approximation of matr_dat

approx_C <- function(matr_dat, fdepths, alpha, B, gamma, grid) {
  
  # infer number of observations from length of depth vector
  n <- length(fdepths)
  # Get number of elements in grid
  grid_length <- length(grid) 
  # determine threshold to drop observations with lowest depth values    
  depth_thr <- quantile(x = fdepths, probs = alpha)
  # drop observations for bootstrapping    
  matr_dat_red <- matr_dat[fdepths >= depth_thr, ]
  n_red <- dim(matr_dat_red)[1]
    
  # Determine vcov-matrix for smoothed bootstrapping    
  Sigma_x <- cov(matr_dat_red)
  my_vcov <- gamma*Sigma_x 

  # Draw bootstrap samples from data set  
  fsamples <- map(.x = 1:B,
                  .f = function(inds) matr_dat_red[sample(x = 1:n_red, size = n, replace = TRUE), ])
  
  # Create smoothing components for bootstrapping                  
  smoothing_components <- map(.x = 1:B,
                              .f = function(x) mvrnorm(n = n, mu = rep(0, times = grid_length), Sigma = my_vcov))
  
  # Obtain smoothed bootstrap samples                                  
  smoothed_BS_samples <- map(.x = 1:B,
                             .f = function(b) fsamples[[b]] + smoothing_components[[b]])

  # Calculate depths for each smoothed bootstrap sample                             
  bootstrap_depths <- map(.x = 1:B,
                          .f = function(b) hM_depth(smoothed_BS_samples[[b]], grid))

  # Calculate first percentile from depths of smoothed bootstrap samples                          
  one_perc_quantiles <- unlist(map(.x = bootstrap_depths,
                                   .f = function(sample) quantile(sample, probs = 0.01)))
  
  # return median of first percentiles                                   
  return(median(one_perc_quantiles))
}
                                   
# matr_dat: data in matrix form - each row contains the grid approximations of one observation
# alpha: quantile of least deep observations to drop before bootstrapping (in approximation of C - optional if C is specified)
# B: number of smoothed bootstrap samples to use (in approximation of C - optional if C is specified)
# gamma: tuning parameter for smoothed bootstrap
# ids: identifiers of individual observations
# grid: grid used in approximation of matr_dat
# C: should be provided. Otherwise C will be approximated in each step of the iteration

outlier_iteration <- function(matr_dat, alpha = 0.05, B = 50, gamma, ids, grid, C = NULL){
    
  # Calculating functional depths using a function from ./auxiliary/Rcpp_functions.cpp  
  fdepths <- hM_depth(matr_dat, grid)
  
  if(missing(C)){
      # Approximating C  
      C <- approx_C(matr_dat = matr_dat, fdepths = fdepths, alpha = alpha,
                    B = B, gamma = gamma, grid = grid)
  }
  
  # Flagging observations with depths lower than the cutoff value C  
  outliers <- which(fdepths < C)
    
  return(list(matr_dat = matr_dat[-outliers, ],
              ids = ids[-outliers],
              outlier_ids = ids[outliers]))
}
                                   
# matr_dat: data in matrix form - each row contains the grid approximations of one observation
# alpha: quantile of least deep observations to drop before bootstrapping (in approximation of C - optional if C is specified)
# B: number of smoothed bootstrap samples to use (in approximation of C - optional if C is specified)
# gamma: tuning parameter for smoothed bootstrap
# ids: identifiers of individual observations
# grid: grid used for the approximation
# C: should be provided. Otherwise C will be approximated in each step of the iteration

outlier_detection <- function(matr_dat, alpha = 0.05, B = 100, gamma = 0.05, ids, grid, C = NULL){
    
    tmp_ids <- ids
    # Initialize empty vectors for position of flagged observations in func_dat and ids of flagged observations
    outlier_ids <- c()
    
    # loop that continues until an iteration does not flag any new observations
    condition <- TRUE
    while(condition){
        
        # perform iteration
        iter_res <- outlier_iteration(matr_dat = matr_dat, alpha = alpha, B = B, gamma = gamma, ids = tmp_ids, grid = grid, C = C)
        new_outliers <- iter_res$outlier_ids
        
        # if there are no new flagged observations stop loop
        if(length(new_outliers) == 0){condition <- FALSE}
        else{
          #otherwise: add flagged observations to vector
          outlier_ids <- c(outlier_ids, new_outliers)
          # reduce data to non-flagged observations
          matr_dat <- iter_res$matr_dat
          # reduce ids to non-flagged observations
          tmp_ids <- iter_res$ids 
        }
    }
    
    # return identifiers of flagged observations and position of these flagged observations in the data set
    return(list(outlier_ids = outlier_ids,
                outlier_ind = which(is.element(ids, outlier_ids))))
}
                                   
# func_dat: list that contains the observations
# each observation is a list, that contains two vectors of identical length: args and vals
# ids: identifiers of individual observations
# alpha: quantile of least deep observations to drop before bootstrapping (in approximation of C - optional if C is specified)
# B: number of smoothed bootstrap samples to use (in approximation of C - optional if C is specified)
# gamma: tuning parameter for smoothed bootstrap

detection_wrap <- function(func_dat, ids, alpha, B, gamma = 0.05){
    
    # determine the grid for approximation
    grid <- grid_finder(func_dat)
    
    # Approximate by linear interpolation
    matr_dat <- grid_approx_set_obs(func_dat, grid)
    
    # calculate h-modal depths
    fdepths <- hM_depth(matr_dat, grid)
    
    # Approximate a value of C
    C_appr <- approx_C(matr_dat = matr_dat, fdepths = fdepths, alpha = alpha, B = B, gamma = gamma, grid = grid)
    
    # Perform the outlier classification procedure for the approximated value of C
    flagged <- outlier_detection(matr_dat = matr_dat, ids = ids, grid = grid, C = C_appr)
    
    # Return the list of outlier ids and outlier indices - these are useful in different cases
    return(flagged)
}
                                   
# list_path: path to the random access list of the data set (generated by package largeList)
# index: index of observations to use in the procedure
# alpha: quantile of least deep observations to drop before bootstrapping (in approximation of C)
# B: number of smoothed bootstrap samples to use (in approximation of C)
# gamma: tuning parameter for smoothed bootstrap

random_access_par_helper <- function(list_path, ids, index, alpha, B, gamma){
    
    # read in the observations identified by the variable index
    func_dat <- readList(file = list_path, index = index)

    # perform the outlier detection procedure on the sample
    # in a tryCatch statement as the procedure creates notamatrix errors in random cases
    sample_flagged <- tryCatch(
        {detection_wrap(func_dat = func_dat, ids = ids, alpha = alpha, B = B, gamma = gamma)},
         error=function(cond){
             return(list(outlier_ids = c(), outlier_ind = c()))}
    )
    
    # return the object generated by the outlier detection procedure
    return(sample_flagged$outlier_ids)
}
                                   
# cl: cluster object generated by parallel package
# n_obs: number of observations in data set
# n_samples: number of samples to use
# sample_size: number of observations to use in each sample
# alpha: quantile of least deep observations to drop before bootstrapping (in approximation of C)
# B: number of smoothed bootstrap samples to use (in approximation of C)
# gamma: tuning parameter for smoothed bootstrap
# list_path: path to the random access list of the data set (generated by package largeList)

sampling_wrap <- function(cl, n_obs, n_samples, sample_size, alpha, B, gamma, list_path){  
    
    ids <- 1:n_obs
    
    # Initialize vectors described in the theoretical section
    num_samples <- rep(x = 0, times = n_obs)
    num_outliers <- rep(x = 0, times = n_obs)
    frac_outliers <- rep(x = 1, times = n_obs)
    
    # Draw indexes for sampling from functional data without replacement
    sample_inds <- map(.x = 1:n_samples, 
                       .f = function(i) sample(x = ids, size = sample_size, replace = FALSE))
    
    # Determine how often each observation appeared in the samples and update the vector                      
    freq_samples <- tabulate(unlist(sample_inds))  
    num_samples[1:length(freq_samples)] <- num_samples[1:length(freq_samples)] + freq_samples                   
    
    # Perform the outlier classification procedure on the chosen samples parallelized
    # with the function clusterApplyLB() from the parallel package                       
    sample_flagged_par <- clusterApplyLB(cl = cl,
                                         x = sample_inds,
                                         fun = function(smpl){
                                             random_access_par_helper(list_path = list_path, ids = ids[smpl],
                                                                      index = smpl, alpha = alpha, 
                                                                      B = B, gamma = gamma)})  
    
    # Determine how often each observation were flagged in the samples and update the vector                     
    freq_outliers <- tabulate(unlist(sample_flagged_par))
    num_outliers[1:length(freq_outliers)] <- num_outliers[1:length(freq_outliers)] + freq_outliers
    
    # termine fraction of samples each observation was flagged as an outlier in                       
    certainties <- unlist(map(.x = 1:n_obs,
                              .f = function(i) ifelse(num_samples[i] != 0, num_outliers[i]/num_samples[i], 1)))
    
    # Return list containing the three central vectors: num_samples, num_outliers, certainties                                  
    return(list(num_samples = num_samples,
                num_outliers = num_outliers,
                certainties = certainties))                              
}
                              
# func_dat: list that contains the observations
# each observation is a list, that contains two vectors of identical length: args and vals

zero_observations <- function(func_dat){
    zeroed_func_dat <- map(.x = func_dat,
                           .f = function(fnc){
                               args = fnc$args - fnc$args[1]
                               return(args = args, vals = fnc$vals)
                           })
    return(zeroed_func_dat)
}
                              
# func_dat: list that contains the observations
# each observation is a list, that conatins two vectors of identical length: args and vals

measuring_int <- function(func_dat){
    intervals <- matrix(data = unlist(map(.x = func_dat,
                                          .f = function(obs) c(min(obs$args), max(obs$args)))),
                        nrow = length(func_dat), byrow = TRUE)
                     
    return(intervals)                     
}
                                      
# measuring_intervals: use output from measuring_int()

unique_intervals <- function(measuring_intervals){
    
    # for finding unique entries transforming to a list is easier
    interval_list <- map(.x = seq_len(nrow(x)), 
                         .f = function(i) measuring_intervals[i,])
                         
    # find unique entries                             
    unique_intervals <- unique(interval_list)
    
    # combine into matrix again                         
    unique_matrix <- matrix(data = unlist(unique_intervals), 
                            nrow = length(unique_intervals),
                            byrow = TRUE)
                         
    # return matrix where each row contains the beginning and end points of a unique measuring interval
    # from the data set
    return(unique_matrix)                         
}
                         
# main_interval: vector of two elements: starting and end point of measuring interval
# measuring_intervals: use output from measuring_int()
# lambda: acceptable stretching parameter
# ids: identifiers of individual observations

comparable_obs_finder <- function(main_interval, measuring_intervals, lambda, ids){
    
    # Determine comparable observations by checking interval endpoints
    comparable <- which(measuring_intervals[,2] >= main_interval[2]/lambda 
                        & measuring_intervals[,2] <= main_interval[2]*lambda)
    
    # Return the correspoding indices and the ids of the comparable observations
    return(list(ind = comparable,
                ids = ids[comparable]))
}
                         
# obs: a list that conatins two vectors of identical length: args and vals
# measuring_interval: a vector with 2 elements, the start and end points of the desired measuring interval

stretch_obs <- function(obs, measuring_interval){
    
    # calculate stretching factor
    phi <- (measuring_interval[2] - measuring_interval[1]) / (max(obs$args) - min(obs$args))
    
    # stretch arguments by appropriate factor
    args_stretched <- obs$args * phi
    
    # return in the format for functional observations
    return(list(args = args_stretched,
                vals = obs$vals))
}
                         
# func_dat: list that contains the observations
# each observation is a list, that conatins two vectors of identical length: args and vals
# measuring_interval: a vector with 2 elements, the start and end points of the desired measuring interval

stretch_data <- function(func_dat, measuring_interval){
    
    # apply function stretch_obs() to each observation in the data set
    stretch_dat <- map(.x = func_dat,
                       .f = function(obs) stretch_obs(obs = obs, measuring_interval = measuring_interval))

    # return list of stretched observations                       
    return(stretch_data)                       
}
                       
# list_path: path to the random access list of the data set (generated by package largeList)
# index: index of observations to use in the procedure
# alpha: quantile of least deep observations to drop before bootstrapping (in approximation of C)
# B: number of smoothed bootstrap samples to use (in approximation of C)
# gamma: tuning parameter for smoothed bootstrap
# measuring_interval: a vector with 2 elements, the start and end points of the desired measuring interval

random_access_par_stretch_helper <- function(list_path, ids, index, alpha, B, gamma, measuring_interval){
    
    # read in the observations identified by the variable index
    func_dat <- stretch_data(func_dat = readList(file = list_path, index = index),
                             measuring_interval = measuring_interval)

    # perform the outlier detection procedure on the sample
    # in a tryCatch statement as the procedure creates notamatrix errors in random cases
    sample_flagged <- tryCatch(
        {detection_wrap(func_dat = func_dat, ids = ids, alpha = alpha, B = B, gamma = gamma)},
         error=function(cond){
             return(list(outlier_ids = c(), outlier_ind = c()))}
    )
    
    # return the object generated by the outlier detection procedure
    return(sample_flagged$outlier_ids)
}
                       
# cl: cluster object generated by parallel package
# n_samples: number of samples to use
# sample_size: number of observations to use in each sample
# alpha: quantile of least deep observations to drop before bootstrapping (in approximation of C)
# B: number of smoothed bootstrap samples to use (in approximation of C)
# gamma: tuning parameter for smoothed bootstrap (in approximation of C)
# list_path: path to the random access list of the data set (generated by package largeList)
# measuring_interval: a vector with 2 elements, the start and end points of the desired measuring interval
# comparable: vector with the indices of comparable observations in the largelist

stretch_and_sample <- function(cl, n_samples, sample_size, alpha, B, gamma, list_path, measuring_interval, comparable){
    
    ids <- comparable
    
    # Initialize vectors described in the theoretical section
    num_samples <- rep(x = 0, times = length(comparable))
    num_outliers <- rep(x = 0, times = length(comparable))
    frac_outliers <- rep(x = 1, times = length(comparable))
    
    # Draw indexes for sampling from functional data without replacement
    sample_inds <- map(.x = 1:n_samples, 
                       .f = function(i) sample(x = ids, size = sample_size, replace = FALSE))
    
    # Determine how often each observation appeared in the samples and update the vector                      
    freq_samples <- tabulate(unlist(sample_inds))  
    num_samples[1:length(freq_samples)] <- num_samples[1:length(freq_samples)] + freq_samples                   
    
    # Perform the outlier classification procedure on the chosen samples parallelized
    # with the function clusterApplyLB() from the parallel package                       
    sample_flagged_par <- clusterApplyLB(cl = cl,
                                         x = sample_inds,
                                         fun = function(smpl){
                                             random_access_par_stretch_helper(list_path = list_path, ids = ids[smpl],
                                                                              index = smpl, alpha = alpha, B = B, gamma = gamma, 
                                                                              measuring_interval = measuring_interval)})  
    
    # Determine how often each observation were flagged in the samples and update the vector                     
    freq_outliers <- tabulate(unlist(sample_flagged_par))
    num_outliers[1:length(freq_outliers)] <- num_outliers[1:length(freq_outliers)] + freq_outliers
    
    # termine fraction of samples each observation was flagged as an outlier in                       
    certainties <- unlist(map(.x = 1:n_obs,
                              .f = function(i) ifelse(num_samples[i] != 0, num_outliers[i]/num_samples[i], 1)))
    
    # Return list containing the three central vectors: num_samples, num_outliers, certainties                                  
    return(list(num_samples = num_samples,
                num_outliers = num_outliers,
                certainties = certainties))
}
                              
# cl: cluster object generated by parallel package
# list_path: path to the random access list of the data set (generated by package largeList)
# measuring_intervals: matrix of measuring intervals
# n_obs: number of observations in the data set
# lambda: acceptable stretching parameter
# n_samples: number of samples to use in each iteration (NULL for procedure determining value)
# sample_size: number of observations to use in each sample in each iteration (NULL for procedure determining value)
# alpha: quantile of least deep observations to drop before bootstrapping (in approximation of C) (NULL for procedure determining value)
# B: number of smoothed bootstrap samples to use (in approximation of C) (NULL for procedure determining value)
# gamma: tuning parameter for smoothed bootstrap (in approximation of C)

dectection_zr_smpl <- function(cl, list_path, measuring_intervals, n_obs, lambda, n_samples = NULL, sample_size = NULL, alpha = NULL, B = NULL, gamma = 0.05){
    
    # generate useful identifies for vectors
    ids <- 1:n_obs
    
    # create vectors as described in the description part
    num_samples <- rep(x = 0, times = n_obs)
    num_outliers <- rep(x = 0, times = n_obs)
    frac_outliers <- rep(x = 1, times = n_obs)
     
    # determine unique intervals to iterate through
    unique_intervals <- unique_intervals(measuring_intervals)
    n_intervals <- dim(unique_intervals)[1]
    
    # iteration process
    for(i in 1:n_intervals){
        
        # Possible output
        #print(paste0(i, " out of ", num_intervals))
        
        # find comparable observations
        comparable <- comparable_obs_finder(main_interval = unique_intervals[i,], 
                                            measuring_intervals = measuring_intervals, 
                                            lambda = lambda, ids = ids)
        
        # do stretching and sampling procedure on current comparable observations
        intv_res <- stretch_and_sample(cl = cl, n_samples = n_samples, sample_size = sample_size, 
                                       alpha = alpha, B = B, gamma = gamma, list_path = list_path,
                                       measuring_interval = measuring_intervals[i], comparable = comparable)
        
        # update the vectors
        num_samples[comparable] <- num_samples[comparable] + intv_res$num_samples
        num_outliers[comparable] <- num_outliers[comparable] + intv_res$num_outliers
    }
    
    # calculate the relative frequency of outliers
    frac_outliers <- unlist(map(.x = 1:n_obs,
                                .f = function(i) ifelse(num_samples[i] != 0, num_outliers[i]/num_samples[i], 1)))
    
    # Return the three vectors                                
    return(list(num_samples = num_samples,
                num_outliers = num_outliers,
                certainties = frac_outliers))                                
}
                                
                                
