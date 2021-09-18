# Function to generate a single observation for set 3:
random_dat <- function(grid, slope, out){
    args <- grid
    if(out == 0){
        vals <- runif(n = length(grid), min = 0.8, max = 1.2) * slope * args + rnorm(n = length(grid), mean = 0, sd = 0.05)
    }
    else if(out == 1){
        vals <- runif(n = length(grid), min = 1, max = 1.4) * 1.2 * slope * args + rnorm(n = length(grid), mean = 0, sd = 0.1)
    }
    else if(out == 2){
        vals <- (slope*max(args)) / (1 + exp(-3*(args - 0.5))) + rnorm(n = length(grid), mean = 0, sd = 0.05)
    }
    else if(out == 3){
        vals <- (slope*max(args)) * (2 / (1 + exp(-3*args)) - 1) + rnorm(n = length(grid), mean = 0, sd = 0.05)
    }
    else if(out == 4){
        vals <- (slope*max(args)) * (exp(args) - 1) / (exp(max(args)) - 1) + rnorm(n = length(grid), mean = 0, sd = 0.05)
    }
    else{
        vals <- runif(n = length(grid), min = 0, max = (slope*max(args)))  
    }
    
    return(list(args = grid,
                vals = vals))
}

# Function to generate the whole set 3:
generate_set_3 <- function(){
        
    # Set seed for reproducibility
    set.seed(17203476)
    
    # Choose comparatively large number of observations
    n <- 30000
    ids <- as.character(1:n)
    
    # Choose ~5% of observations as outliers
    outliers <- sample(x = 0:5, size = n, prob = c(0.95, rep(0.01, times = 5)), replace = TRUE)
    
    # Choose number of measurements for each observation
    lengths <- sample(x = 10:100, size = n, replace = TRUE)
    
    # Choose interval endpoint for each observation (make discrete set for ease of use)
    end_points <- sample(x = c(0.9, 1, 1.1, 1.5, 1.6, 1.7, 1.9, 2, 2.1), 
                         prob = c(0.05, 0.2, 0.05, 0.07, 0.15, 0.08, 0.1, 0.25, 0.05),
                         size = n,
                         replace = TRUE)
    
    # Find points of measurement for each observation
    # 0 and 1 are part of each grid to ensure identical measuring interval
    grids <- purrr::map(.x = lengths,
                        .f = function(l) c(0, sort(runif(n = l-2, min = 0, max = end_points[l])), end_points[l]))
                        
    # Create observations
    functions <- map(.x = 1:n,
                     .f = function(i) random_dat(grid = grids[[i]], slope = 1.02, out = outliers[i]))
                     
    # Save data in random access format
    saveList(functions, "./data/Set_3/functional.llo")
    saveRDS(ids, "./data/Set_3/ids.RDS")
    saveRDS(which(outliers != 0), "./data/Set_3/outliers.RDS")
    return(list(data = functions, ids = ids, outliers = which(outliers != 0)))
}
                     
# bring into tidy format                     
tidify_3 <- function(data_set, ids){
    
    # extract arguments
    x_1 <- unlist(map(.x = data_set,
                      .f = function(fun) fun$args))
                      
    # extract values                          
    y_1 <- unlist(map(.x = data_set,
                      .f = function(fun) fun$vals))
    # calculate lengths                      
    len <- unlist(map(.x = data_set,
                      .f = function(fun) length(fun$args))) 
                      
    # make fitting repetitions of ids                      
    ids <- unlist(map(.x = 1:30000,
                      .f = function(i) rep(ids[i], times = len[i]))) 
    
    # make into tibble                      
    tibbled <-  tibble(x = x_1, 
                       y = y_1,
                       ids = ids)  
                      
    return(tibbled)
}
                      
vis_3 <- function(tidy_3){
    p <- ggplot(data = tidy_3) +
            ggtitle("Data Set 3") +
            geom_line(aes(x = x, y = y, group = ids), col = "blue", alpha = 0.1) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18))
    
    ggsave(plot = p, filename = "./material/set_3.png", width = 50, height = 15, units = "cm")
    
    p
}
