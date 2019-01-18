library(shiny)
library(tidyverse)

# load data
dat <- read.csv('../data/crime_lat_long.csv')

# set crimes for select box input
crimes_list <- c("Total Crime" = "violent_per_100k",
                 "Homicide" = "homs_per_100k",
                 "Rape" = "rape_per_100k",
                 "Robbery" = "rob_per_100k",
                 "Aggrevated Assault" = "agg_ass_per_100k")
# get cities for select box input
city_list <- as.list(as.vector(dat$city))

# main structure
ui <- fluidPage(
  
  # sed a title
  titlePanel("Marshall Project Crime Database",
             windowTitle = "Crime Data"),
  
  # app layout
  sidebarLayout(

    sidebarPanel(
      # slider bar: input year
      sliderInput("year_input", "Select a year",
                  min = 1975, max = 2015, value = 2000),
      # select box: crime type
      selectInput("crime_input", "Select a crime", crimes_list),
      # select box: input city
      selectInput("city_input", "Select a city", city_list)
    ),

    mainPanel(
      tabsetPanel(
        tabPanel(title = "Map", leafletOutput("mymap")),
        tabPanel(title = "Single City",
                 plotOutput("line_chart"),
                 tableOutput("percentage_table"))
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # get city data for line chart
  single_city_dat <- reactive(
    dat %>% 
      filter(city == input$city_input) %>%
      select(year, total_pop, 
             violent_per_100k, homs_per_100k, rape_per_100k, 
             rob_per_100k, agg_ass_per_100k) %>% 
      mutate(total_pop = total_pop/1000)
  )
  
  # get the city rank for current year
  city_rank <- reactive(
    dat %>% 
      filter(year == input$year_input) %>%
      mutate(Rank = dense_rank(violent_per_100k)) %>% 
      filter(city == input$city_input)
    )
  
  # get the average table for current year
  avg <- reactive(
    dat %>% 
      filter(year == input$year_input) %>% 
      group_by(year) %>% 
      summarise(homs = mean(homs_per_100k, na.rm = TRUE),
                rape = mean(rape_per_100k, na.rm = TRUE),
                rob = mean(rob_per_100k, na.rm = TRUE),
                agg = mean(agg_ass_per_100k, na.rm = TRUE))
    )
  
  #Get the size for the map circles
  crime_circles <- reactive (
    dat %>%
      filter(year == input$year_input) %>% 
      select(input$crime_input) %>% 
      mutate(calc = (.[[1]]-mean(.[[1]],na.rm = TRUE))/sd(.[[1]],na.rm=TRUE))
  )

  
  # Map output
  output$mymap <- renderLeaflet({
    leaflet(dat) %>%
      addTiles() %>%
      addCircleMarkers(lng = ~lon, 
                       lat = ~lat, 
                       radius = 3*crime_circles()$calc, 
                       color = "blue",
                       fillOpacity = 0.5,
                       popup = ~city)
  })
  
  # line chart for trend
  output$line_chart <- renderPlot(
    single_city_dat() %>%
      gather(total_pop, violent_per_100k, homs_per_100k, 
             rape_per_100k, rob_per_100k, agg_ass_per_100k,
             key = "type", value = "count") %>%
      ggplot(aes(x = year, y = count, color = type)) +
      geom_line()
  )
  
  # table for percentage
  output$percentage_table <- renderTable(
    single_city_dat() %>% 
      filter(year == input$year_input) %>% 
      # calculate average compare to national and add % to the end
      mutate(homs_per_100k = paste(round((homs_per_100k - avg()$homs)/100, 
                                         digits = 2), "%"),
             rape_per_100k = paste(round((rape_per_100k - avg()$rape)/100, 
                                         digits = 2), "%"),
             rob_per_100k = paste(round((rob_per_100k - avg()$rob)/100, 
                                         digits = 2), "%"),
             agg_ass_per_100k = paste(round((agg_ass_per_100k - avg()$agg)/100, 
                                         digits = 2), "%"),
             rank = city_rank()$Rank) %>% 
      # clean up table names
      select("Year" = year,
             "Homicide" = homs_per_100k,
             "Rape" = rape_per_100k,
             "Robbery" = rob_per_100k,
             "Aggrevated Assault" = agg_ass_per_100k,
             "Safety Rank" = rank)
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)

