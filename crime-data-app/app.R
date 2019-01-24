library(shiny)
library(tidyverse)
library(leaflet)
library(rsconnect)

# load data
dat <- read.csv('crime_lat_long.csv')

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
  titlePanel(h2("Violent Crime Rates in the United States", align = 'center'),
             windowTitle = "Crime Data"),
  
  # new panel with two tabs
  tabsetPanel(
    # Map tab
    tabPanel(
      title = "Map",
      sidebarLayout(
        # siderbar for map
        sidebarPanel(
          sliderInput("year_input", "Select a year",
                      min = 1975, max = 2014, value = 2000, 
                      width = '100%', sep=""),
          selectInput("crime_input", "Select a crime", crimes_list)
        ),
        # main panel for map
        mainPanel(leafletOutput("mymap"))
      )
    ),
    # Chart tab
    tabPanel(
      title = "Single City",
      sidebarLayout(
        # sidebar for chart, input name changed
        sidebarPanel(
          sliderInput("year_input_chart", "Select a year",
                      min = 1975, max = 2014, value = 2000, 
                      width = '100%', sep=""),
          selectInput("city_input", "Select a city", 
                      selected = as.factor(levels(city_list)[1]), city_list)
        ),
        # main panel
        mainPanel(
          plotOutput("line_chart"),
          "Comparisions to national average (from the data) of the current year,",
          "safety rank out of 67 cities:",
          tableOutput("percentage_table")
        )
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
  
  # get city data prepared for plotting lines
  single_city_line <- reactive(
    single_city_dat() %>% 
      gather(total_pop, violent_per_100k, homs_per_100k, 
             rape_per_100k, rob_per_100k, agg_ass_per_100k,
             key = "type", value = "count")
  )
  
  # get the city rank for current year
  city_rank <- reactive(
    dat %>% 
      filter(year == input$year_input_chart) %>%
      mutate(Rank = dense_rank(violent_per_100k)) %>% 
      filter(city == input$city_input)
    )
  
  # get the average table for current year
  avg <- reactive(
    dat %>% 
      filter(year == input$year_input_chart) %>% 
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
    ggplot() +
      geom_line(data = single_city_line(), 
                aes(x = year, y = count, color = type)) +
      geom_bar(data = single_city_dat(), 
               aes(x = year, y = total_pop),
               stat="identity", fill = 'blue', alpha = 0.2) +
      scale_color_discrete(labels = c("Aggrevated Assault", "Homicide", "Rape", "Robbery", "Population (k)", "Total Crime"), name = "" ) + 
      theme_bw() +
      xlab("Year") + 
      ylab("Crime Rate per 100k People")
  )
  
  # table for percentage
  output$percentage_table <- renderTable(
    single_city_dat() %>% 
      filter(year == input$year_input_chart) %>% 
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

