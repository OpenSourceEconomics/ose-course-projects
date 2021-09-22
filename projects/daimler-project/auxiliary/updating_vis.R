set.seed(293847)
N <- 100000  
U <- runif(N)

my_RV <- rep(NA, times = N)
    
my_RV[which(U < 0.3)] <- rnorm(n = sum(U < 0.3), mean = 5, sd = 1)
my_RV[which(U >= 0.3 & U < 0.8)] <- rnorm(n = sum(U >= 0.3 & U < 0.8), mean = 9, sd = 2)
my_RV[which(U >= 0.8)] <- rnorm(n = sum(U >= 0.8), mean = 14, sd = 1)

my_dens <- approxfun(density(my_RV))

upd_1_vis <- function(){
    
    my_tibble <- tibble(x = seq(0, 22, length.out = 1000),
                        y = my_dens(x))
    
    AS <- 1.2
    
    sec_tibble <- tibble(my_x = seq(0, 18, length.out = 500),
                         rec_b = c(rep(7, times = 162), rep(my_x[163], times = 500-162)),
                         rec_e = c(rep(7, times = 162), my_x[163:232], rep(my_x[233], times = 500-232)))
    
    p <- ggplot(data = sec_tibble) +
            geom_line(data = my_tibble, aes(x = x, y = y), col = "red", lwd = 1) +
            ggtitle("Updating Window") +
            xlab("Endpoint of Measuring Interval") + ylab("Density") +
            geom_rect(aes(xmin = rec_b, xmax = rec_e, ymin = 0, ymax = 0.15, group = seq_along(my_x)), col = "blue", fill = "blue", alpha = 0.2) +
            geom_segment(x = 7, xend = 7, y = 0, yend = 0.15, col = "black") +
            annotate("text", x = 11, y = 0.02, label = "Updating Window", size = 8, col = "blue") +
            annotate("rect", xmin = 8.7, xmax = 13.3, ymin = 0.01, ymax = 0.03, fill = "blue", alpha = 0.1, col = "blue") +
            annotate("text", x = 11, y = 0.13, label = "New Observation", size = 8, col = "black") +
            annotate("rect", xmin = 8.7, xmax = 13.3, ymin = 0.12, ymax = 0.14, fill = "black", alpha = 0.05, col = "black") +
            geom_segment(x = 11, xend = 7, y = 0.12, yend = 0.09, col = "black", arrow = arrow()) +
            geom_rect(aes(xmin = my_x / AS, xmax = my_x * AS, ymin = 0, ymax = 0.15, group = seq_along(my_x)), col = "green", fill = "green", alpha = 0.2) +
            geom_segment(aes(x = my_x, xend = my_x, y = 0, yend = 0.15, group = seq_along(my_x)), col = "blue") +
            xlim(0, 22) + ylim(0, 0.15) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18)) +
            transition_states(my_x, transition_length = 1, state_length = 1)
    
    anim <- animate(p, nframes = 1000, fps = 40, renderer = gifski_renderer(file = './material/update_1.gif'),
                height = 500, width = 1000)
    
    anim  
}

pot_upd_obs_vis <- function(){
    
    my_tibble <- tibble(x = seq(0, 22, length.out = 1000),
                        y = my_dens(x))
    
    AS <- 1.2
    
    sec_tibble <- tibble(my_x = seq(0, 18, length.out = 500),
                         rec_b = c(rep(7, times = 162), rep(my_x[163] / AS, times = 500-162)),
                         rec_e = c(rep(7, times = 162), my_x[163:232] * AS, rep(my_x[233]*AS, times = 500-232)))
    
    p <- ggplot(data = sec_tibble) +
            geom_line(data = my_tibble, aes(x = x, y = y), col = "red", lwd = 1) +
            ggtitle("Potentially Updated Observations") +
            xlab("Endpoint of Measuring Interval") + ylab("Density") +
            geom_rect(aes(xmin = rec_b, xmax = rec_e, ymin = 0, ymax = 0.15, group = seq_along(my_x)), col = "red", fill = "red", alpha = 0.1) +
            geom_segment(x = 7, xend = 7, y = 0, yend = 0.15, col = "black") +
            annotate("text", x = 12.8, y = 0.013, label = "Potentially updated \n observations", size = 8, col = "red") +
            annotate("rect", xmin = 10.2, xmax = 15.4, ymin = 0, ymax = 0.026, fill = "red", alpha = 0.1, col = "red") +
            annotate("text", x = 13, y = 0.13, label = "New Observation", size = 8, col = "black") +
            annotate("rect", xmin = 10.7, xmax = 15.3, ymin = 0.12, ymax = 0.14, fill = "black", alpha = 0.05, col = "black") +
            geom_segment(x = 13, xend = 7, y = 0.12, yend = 0.09, col = "black", arrow = arrow()) +
            geom_rect(aes(xmin = my_x / AS, xmax = my_x * AS, ymin = 0, ymax = 0.15, group = seq_along(my_x)), col = "green", fill = "green", alpha = 0.2) +
            geom_segment(aes(x = my_x, xend = my_x, y = 0, yend = 0.15, group = seq_along(my_x)), col = "blue") +
            xlim(0, 22) + ylim(0, 0.15) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18)) +
            transition_states(my_x, transition_length = 1, state_length = 1)
    
    anim <- animate(p, nframes = 1000, fps = 40, renderer = gifski_renderer(file = './material/update_2.gif'),
                height = 500, width = 1000)
    
    anim  
}

upd_2_vis <- function(){
    
    my_tibble <- tibble(x = seq(0, 18, length.out = 1000),
                        y = my_dens(x))
    
    p <- ggplot(data = my_tibble) +
            geom_line(aes(x = x, y = y), col = "red", lwd = 1) +
            ggtitle("Distribution of Endpoints") +
            xlab("Endpoint of Measuring Interval") + ylab("Density") +
            geom_segment(x = 11, xend = 7, y = 0.12, yend = 0.09, col = "black", arrow = arrow()) +
            geom_segment(x = 7, xend = 7, y = 0, yend = 0.15, col = "blue", lwd = 1) +
            geom_rect(inherit.aes = FALSE, xmin = 7/1.2, xmax = 7*1.2, ymin = 0, ymax = 0.15, col = "red", fill = "red", alpha = 0.002) +
            annotate("text", x = 11, y = 0.13, label = "New Observation", size = 8, col = "black") +
            annotate("rect", xmin = 8.7, xmax = 13.3, ymin = 0.12, ymax = 0.14, fill = "black", alpha = 0.05, col = "black") +
            xlim(0, 18) + ylim(0, 0.15) +
            theme_light() +
            theme(plot.title = element_text(size=24),
                  axis.title.x = element_text(size=18),
                  axis.title.y = element_text(size=18))
    
    ggsave(filename = "./material/update_3.png", plot = p, width = 5000, height = 2500, units = "px")  
        
}
