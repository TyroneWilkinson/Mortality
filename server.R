
shinyServer(function(input, output, session){
  # Show map using leaflet
  output$map <- renderLeaflet({
    popup <- paste0("State of ",
                    merged_df$state_name,
                    "<br>",
                    merged_df$location_name,
                    "<br>")
    leaflet(data=merged_df) %>%
      addProviderTiles("Esri.WorldStreetMap") %>% 
      setView(-96.5, 38, zoom = 4) %>% 
    addPolygons(color = "#b2aeae", # you need to use hex colors
                fillOpacity = 0.7,
                weight = 1,
                layerId = ~loc,
                smoothFactor = 0.2,
                popup = popup)
  })
  
  select_column <- reactive({
    merged_df %>% select(input$main)
  })
  
  # Map changes
  observe({
    main_column <- select_column()
    pal <- colorNumeric(
      palette = "YlGnBu",
      domain = main_column[[1]]
    )
    leafletProxy("map", session, data = merged_df) %>%
      clearControls() %>%
      setShapeStyle(layerId = ~loc, fillColor = pal(main_column[[1]])) %>%
      addLegend(pal = pal,
                values = main_column[[1]],
                position = "bottomright",
                title = "Mortality Rate per </br>100,000 people (2014)")
  })
  
  # Show data using DataTable
  output$table <- DT::renderDataTable({
    datatable(merged_df, rownames=FALSE, selection = 'none', options = list(
      scrollX=T,
      pageLength = 20,
      lengthMenu = c(5, 10, 15, 20, 25, 50, 100),
      columnDefs = list(list(visible = FALSE, targets = c(27, 28)))
      )) %>% 
      formatStyle(input$main, background="skyblue", fontWeight='bold')
  })
  
  st_set_geom <- reactive({
    select_column() %>% st_set_geometry(NULL)
  })
  
  # Create and display charts based on user input
  output$bars <- renderPlot({
    ggplot(data = states, 
           aes(x = reorder(state_name, get(input$main)), y = get(input$main), color = state_name)) +
      geom_bar(stat='identity') +
      coord_flip() +
      theme(legend.position="bottom") +
      ggtitle("Mortality Rate (per 100,000 people) by State (2014)") +
      xlab("States") +
      ylab(input$main) +
      labs(color = "States") +
      theme(plot.title = element_text(face = "bold"))
  })
  
  output$line1 <- renderPlot({
    all.state.years %>% 
      filter(state_name %in% input$states_chooser) %>% 
      select(c(1:3, input$main)) %>% 
      ggplot(aes(x = year, y = get(input$main), color = state_name)) +
      ggtitle("Mortality Rate (per 100,000 people) by Year for Select States (1980-2014)") +
      geom_line() +
      xlab("Year") +
      ylab(input$main) + 
      labs(color = "States") +
      theme(plot.title = element_text(face = "bold")) + 
      theme_bw() 
  })
  output$line2 <- renderPlot({
    country.years %>% 
      select(c(1:2, input$main)) %>% 
      ggplot(aes(x = year, y = get(input$main))) +
      ggtitle("Mortality Rate (per 100,000 people) by Year for the Country (1980-2014)") +
      geom_line() +
      xlab("Year") +
      ylab(input$main) + 
      theme(plot.title = element_text(face = "bold")) + 
      theme_bw() 
  })
  output$line3 <- renderPlot({
    og.country.years %>% 
      filter(cause_name %in% input$death_chooser) %>% 
      ggplot(aes(x = year, y = mx, color = cause_name)) +
      ggtitle("Select Mortality Rates (per 100,000 people) by Year for the Country (1980-2014)") +
      geom_line() +
      xlab("Year") +
      ylab("Mortality Rate") + 
      labs(color = "Cause of Death") +
      theme(plot.title = element_text(face = "bold")) + 
      theme_bw() +
      scale_color_viridis(discrete = TRUE)
  })

  # Show statistics using infoBox
  output$maxBox <- renderInfoBox({
    set_geom <- st_set_geom()
    max_value <- 
      max(set_geom)
    max_state <-
      merged_df$state_name[set_geom == max_value] 
    max_county <-
      merged_df$location_name[set_geom == max_value]
    infoBox(title = max_state, 
            value = round(max_value, digits=3),
            subtitle = max_county,
            icon = icon("hand-o-up"))
  })
  output$minBox <- renderInfoBox({
    set_geom <- st_set_geom()
    min_value <- 
      min(set_geom)
    min_state <-
      merged_df$state_name[set_geom == min_value]
    min_county <-
      merged_df$location_name[set_geom == min_value]
    infoBox(title = min_state,
            value = round(min_value, digits=3),
            subtitle = min_county, 
            icon = icon("hand-o-down"))
  })
  output$avgBox <- renderInfoBox(
    
    infoBox(paste("AVG.", input$main),
            round(mean(st_set_geom()[[1]]), digits=3), 
            icon = icon("calculator"), fill = TRUE))

})
