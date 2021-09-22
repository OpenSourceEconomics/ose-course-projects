# Function to generate a single observation for set 2:
random_dat <- function(grid, slope, out){
    args <- grid
    if(out == 0){
        vals <- runif(n = length(grid), min = 0.8, max = 1.2) * slope * args + rnorm(n = length(grid), mean = 0, sd = 0.05)
    }
    else if(out == 1){
        vals <- runif(n = length(grid), min = 1, max = 1.4) * 1.2 * slope * args + rnorm(n = length(grid), mean = 0, sd = 0.1)
    }
    else if(out == 2){
        vals <- 1 / (1 + exp(-3*(args - 0.5))) + rnorm(n = length(grid), mean = 0, sd = 0.05)
    }
    else if(out == 3){
        vals <- 2 / (1 + exp(-3*args)) - 1 + rnorm(n = length(grid), mean = 0, sd = 0.05)
    }
    else if(out == 4){
        vals <- (exp(args) - 1) / 1.7183 + rnorm(n = length(grid), mean = 0, sd = 0.05)
    }
    else{
        vals <- runif(n = length(grid))
    }
    
    return(list(args = grid,
                vals = vals))
}

# Function to generate the whole set 2:
generate_set_2 <- function(){
    
    # Set seed for reproducibility
    set.seed(17203476)

    # Choose comparatively large number of observations
    n <- 10000
    ids <- as.character(1:n)

    # Choose ~5% of observations as outliers
    outliers <- sample(x = 0:5, size = n, prob = c(0.95, rep(0.01, times = 5)), replace = TRUE)
    
    # Choose number of measurements for each observation
    lengths <- sample(x = 10:100, size = n, replace = TRUE)
    
    # Find points of measurement for each observation
    # 0 and 1 are part of each grid to ensure identical measuring interval
    grids <- purrr::map(.x = lengths,
                        .f = function(l) c(0, sort(runif(n = l-2, min = 0, max = 1)), 1))
    
    # Create observations
    functions <- map(.x = 1:n,
                     .f = function(i) random_dat(grid = grids[[i]], slope = 1.02, out = outliers[i]))
                     
    # Save data in random access format
    saveList(functions, "./data/Set_2/functional.llo")
    saveRDS(ids, "./data/Set_2/ids.RDS")
    saveRDS(which(outliers != 0), "./data/Set_2/outliers.RDS")
    return(list(data = functions, ids = ids, outliers = which(outliers != 0)))                 
}

# bring into tidy format                     
tidify_2 <- function(data_set, ids){
    
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
    ids <- unlist(map(.x = 1:10000,
                      .f = function(i) rep(ids[i], times = len[i]))) 
    
    # make into tibble                      
    tibbled <-  tibble(x = x_1, 
                       y = y_1,
                       ids = ids)  
                      
    return(tibbled)
}

vis_2 <- function(tidy_2){
    p <- ggplot(data = tidy_2) +
            ggtitle("Data Set 2") +
            geom_line(aes(x = x, y = y, group = ids), col = "blue", alpha = 0.1) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18))
    
    p
}
