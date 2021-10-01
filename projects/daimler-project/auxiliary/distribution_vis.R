set.seed(293847)
N <- 100000  
U <- runif(N)
    
my_RV <- rep(NA, times = N)
    
my_RV[which(U < 0.3)] <- rnorm(n = sum(U < 0.3), mean = 5, sd = 1)
my_RV[which(U >= 0.3 & U < 0.8)] <- rnorm(n = sum(U >= 0.3 & U < 0.8), mean = 9, sd = 2)
my_RV[which(U >= 0.8)] <- rnorm(n = sum(U >= 0.8), mean = 14, sd = 1)

my_dens <- approxfun(density(my_RV))

dist_vis <- function(){
    
    my_tibble <- tibble(x = seq(0, 18, length.out = 1000),
                        y = my_dens(x))
    
    p <- ggplot(data = my_tibble) +
            geom_line(aes(x = x, y = y)) +
            ggtitle("Distribution of Endpoints") +
            xlab("Endpoint of Measuring Interval") + ylab("Density") +
            xlim(0, 18) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18))
    
    ggsave(filename = "./material/dist.png", plot = p, width = 5000, height = 2500, units = "px")  
        
}

static_splits_vis <- function(){
    
    my_tibble <- tibble(x = seq(0, 18, length.out = 1000),
                        y = my_dens(x))
    
    partition_tibble <- tibble(type = c(rep("A", times = 8),
                                        rep("B", times = 6),
                                        rep("C", times = 5),
                                        rep("D", times = 9)),
                              splitpoints_l = c(sort(c(0, 2.6, 5/1.2, 5*1.2, 9/1.2, 9*1.2, 14 / 1.2, 14*1.2)),
                                              c(0, 3, 6, 9, 12, 15),
                                              c(0, 2, 5, 9, 14),
                                              c(0, 1, 2, 4, 6, 9, 12, 14, 17)),
                              splitpoints_u = c(sort(c(2.6, 5/1.2, 5*1.2, 9/1.2, 9*1.2, 14 / 1.2, 14*1.2, 18)),
                                              c(3, 6, 9, 12, 15, 18),
                                              c(2, 5, 9, 14, 18),
                                              c(1, 2, 4, 6, 9, 12, 14, 17, 18)),
                              split = c(sample(letters, 8, replace = FALSE),
                                        sample(letters, 6, replace = FALSE),
                                        sample(letters, 5, replace = FALSE),
                                        sample(letters, 9, replace = FALSE)))
    
    p <- ggplot(data = partition_tibble) +
            geom_line(data = my_tibble, aes(x = x, y = y), col = "red", lwd = 1) +
            ggtitle("Possible Partitions") +
            xlab("Endpoint of Measuring Interval") + ylab("Density") +
            geom_rect(aes(xmin = splitpoints_l, xmax = splitpoints_u, ymin = 0, ymax = 0.15, fill = split, group = type), col = "blue", alpha = 0.2) +
            xlim(0, 18) + ylim(0, 0.15) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18)) +
            guides(fill = FALSE) +
            transition_states(type, transition_length = 1, state_length = 1)
    
    anim <- animate(p, nframes = 400, fps = 40, renderer = gifski_renderer(file = './material/static_splits.gif'),
                height = 500, width = 1000)
    
    anim         
}

dynamic_splits_vis <- function(){
    
    my_tibble <- tibble(x = seq(0, 22, length.out = 1000),
                        y = my_dens(x))
    
    AS <- 1.2
    
    sec_tibble <- tibble(my_x = seq(0, 18, length.out = 500))
    
    p <- ggplot(data = sec_tibble) +
            geom_line(data = my_tibble, aes(x = x, y = y), col = "red", lwd = 1) +
            ggtitle("Dynamic Splitting") +
            xlab("Endpoint of Measuring Interval") + ylab("Density") +
            geom_rect(aes(xmin = my_x / AS, xmax = my_x * AS, ymin = 0, ymax = 0.15, group = seq_along(my_x)), col = "green", fill = "green", alpha = 0.2) +
            geom_segment(aes(x = my_x, xend = my_x, y = 0, yend = 0.15, group = seq_along(my_x)), col = "blue") +
            xlim(0, 22) + ylim(0, 0.15) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18)) +
            transition_states(my_x, transition_length = 1, state_length = 1)
    
    anim <- animate(p, nframes = 1000, fps = 40, renderer = gifski_renderer(file = './material/dyn_splits.gif'),
                height = 500, width = 1000)
    
    anim    
}

dynamic_splits2_vis <- function(){
    
    my_tibble <- tibble(x = seq(0, 22, length.out = 1000),
                        y = my_dens(x))
    
    sec_tibble <- tibble(my_x = seq(0, 18, length.out = 500),
                         dens = my_dens(my_x),
                         AS = 1 + 0.2 * 1/(1 + 5*dens),
                         x_min = my_x / AS,
                         x_max = my_x * AS)
    
    p <- ggplot(data = sec_tibble) +
            geom_line(data = my_tibble, aes(x = x, y = y), col = "red", lwd = 1) +
            ggtitle("Dynamic Splitting with varying acceptable stretching") +
            xlab("Endpoint of Measuring Interval") + ylab("Density") +
            geom_rect(aes(xmin = x_min, xmax = x_max, ymin = 0, ymax = 0.15, group = seq_along(my_x)), col = "green", fill = "green", alpha = 0.2) +
            geom_segment(aes(x = my_x, xend = my_x, y = 0, yend = 0.15, group = seq_along(my_x)), col = "blue") +
            xlim(0, 22) + ylim(0, 0.15) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18)) +
            transition_states(my_x, transition_length = 1, state_length = 1)
    
    anim <- animate(p, nframes = 1000, fps = 40, renderer = gifski_renderer(file = './material/dyn_splits2.gif'),
                height = 500, width = 1000)
    
    anim    
}
