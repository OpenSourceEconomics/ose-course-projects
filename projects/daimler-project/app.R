library(shiny)
library(shinydashboard)
library(tidyverse)

### load data for different data sets
# set 1:
set_1_summary <- readRDS(file = "./data/Set_1/summary.RDS")
set_1_tibble <- readRDS(file = "./data/Set_1/shiny_tibble.RDS")

# set 2:
set_2_tibble <- readRDS(file = "data/Set_2/shiny_tibble.RDS")
set_2_summary <- list(original = readRDS(file = "data/Set_2/outliers.RDS"))

# set 3:
set_3_tibble <- readRDS(file = "data/Set_3/shiny_tibble.RDS")
set_3_summary <- list(original = readRDS(file = "data/Set_3/outliers.RDS"))

header <- dashboardHeader(
  title = "Outlier Detection"
)

sidebar <- dashboardSidebar(
  selectInput("SET", "Data Set",
              c("Data Set 1" = "set_1",
                "Data Set 2" = "set_2",
                "Data Set 3" = "set_3")),
  sliderInput("OUT_THR", "Observations over which certainty threshold shall be marked as outliers?", min = 0, max = 1, value = 0.5, step = 0.01),
  sliderInput("CERT_THR", "Show observations with certainty values over this threshold:", min = 0, max = 1, value = 0.5, step = 0.01),
  numericInput("OBS_ID", "Which observation do you want to highlight?", value = NA),
  numericInput("L_BORDER", "What is the lower bound of the window you want to see?", value = NA),
  numericInput("R_BORDER", "What is the upper bound of the window you want to see?", value = NA)
)

body <- dashboardBody(
  column(width = 12,
         fluidRow(width = 12,
                  column(width = 7,
                         box(title = "Description", 
                             width = 9, h4("This dashboard visualizes the method of outlier detection used in the project. \n"))),
                  column(width = 5,
                         infoBox("Observations", textOutput("n_obs"), icon = icon("list")),
                         infoBox("Flagged", textOutput("nflagged"), icon = icon("list")))
         )
  ),
  fluidRow(width = 12,
           box(width = 12,
               title = "Plotted Observations",
               plotOutput("my_plot"))
  ),
  fluidRow(width = 12,
           column(12,
                  tabBox(width = 12,
                         title = 'Information',
                         tabPanel("Flagged Observations", 
                                  h3("Flagged observations: "),
                                  h4(textOutput("flagged")),
                         ),
                         tabPanel("Missed Outliers", 
                                  h3("Missed Outliers: "),
                                  h4(textOutput("missed")),
                         ),
                         tabPanel("False Outliers:", 
                                  h3("False outliers: "),
                                  h4(textOutput("false")),
                         )
                  )      
           )
  )
)


ui <- dashboardPage(
  header,
  sidebar,
  body
)

server <- function(input, output, session) {
  
  my_tibble <- reactive({
    if(input$SET == "set_1"){my_tibble <- set_1_tibble}
    if(input$SET == "set_2"){my_tibble <- set_2_tibble}
    if(input$SET == "set_3"){my_tibble <- set_3_tibble}
    my_tibble
  })
  
  info_list <- reactive({
    if(input$SET == "set_1"){info_list <- set_1_summary}
    if(input$SET == "set_2"){info_list <- set_2_summary}
    if(input$SET == "set_3"){info_list <- set_3_summary}
    info_list
  })
  
  show_which <- reactive({
    tmp <- my_tibble()
    if(input$SET == "set_1"){
      show_which <- 1:(dim(tmp)[1])
    } else{
      CERT_THR <- input$CERT_THR
      show_which <- sort(unique(c(which(tmp$cert >= CERT_THR),
                                which(tmp$ids == input$OBS_ID))))
    }
    show_which
  })
  
  out_which <- reactive({
    tmp <- my_tibble()
    if(input$SET == "set_1"){
      out_which <- unique(tmp$ids[which(tmp$flagged == TRUE)])
    } else{
      OUT_THR <- input$OUT_THR
      out_which <- unique(tmp$ids[which(tmp$cert >= OUT_THR)])
    }
    out_which
  })
  
  output$n_obs <- renderText(length(unique(my_tibble()$ids))) # works
  output$flagged <- renderText(out_which())
  output$nflagged <- renderText(length(out_which()))
  output$missed <- renderText(setdiff(info_list()$original, out_which()))
  output$false <- renderText(setdiff(out_which(), info_list()$original))
  
  sizes <- reactive({
    tmp <- my_tibble()
    s <- rep(0.1, times = dim(tmp)[1])
    focus <- which(tmp$ids == input$OBS_ID)
    s[focus] <- 5
    s
  })
  
  output$my_plot <- renderPlot({
    
    plot_tibble <- my_tibble()[show_which(),]
    
    if(input$SET != "set_1"){
      
    ggplot(data = plot_tibble) +
      geom_line(aes(x = x, y = y, col = cert, group = ids), alpha = 50/length(unique(plot_tibble$ids[show_which()]))) +
      geom_line(data = plot_tibble[which(plot_tibble$ids == input$OBS_ID),],
                aes(x = x, y = y), col = "black", lwd = 0.5) +
      scale_color_gradient(low = "#0062ff", high = "#ff0000") +
      theme(text=element_text(size=16, family="Serif")) +
      xlim(ifelse(!is.na(input$L_BORDER), input$L_BORDER, 0), ifelse(!is.na(input$R_BORDER), input$R_BORDER, 1)) +
      guides(col = "none") 
      
    } else{
      
      ggplot(data = plot_tibble) +
        geom_line(aes(x = x, y = y, col = !flagged, group = ids), alpha = 50/length(unique(plot_tibble$ids[show_which()]))) +
        geom_line(data = plot_tibble[which(plot_tibble$ids == input$OBS_ID),],
                  aes(x = x, y = y), col = "black", lwd = 0.5) +
        theme(text=element_text(size=16, family="Serif")) +
        xlim(ifelse(!is.na(input$L_BORDER), input$L_BORDER, 0), ifelse(!is.na(input$R_BORDER), input$R_BORDER, 1)) +
        guides(col = "none")  
      
    }
  })
}

shinyApp(ui, server)
