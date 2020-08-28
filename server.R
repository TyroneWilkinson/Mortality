
shinyServer(function(input, output, session){
  # Show map using leaflet
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("Esri.WorldStreetMap") %>% 
      setView(-96.5, 38, zoom = 4) #%>% 
      # addPolygons(data = merged_df,
      #             color = "#b2aeae", # you need to use hex colors
      #             fillOpacity = 0.7,
      #             weight = 1,
      #             smoothFactor = 0.2)
  })
  
  # Map changes
  observe({
    cause <- input$selected
    popup <- paste0("State of ",
                    merged_df$state_name,
                    "<br>",
                    merged_df$location_name,
                    "<br>",
                    cause, ": ",
                    (merged_df %>% 
                       filter(state_name == merged_df$state_name, location_name == merged_df$location_name) %>% 
                       select(cause))[[1]] %>% round(digits = 3))
    pal <- colorNumeric(
      palette = "YlGnBu",
      domain = (merged_df %>% select(cause))[[1]]
    )
    leafletProxy("map", session, data = merged_df) %>%
      clearShapes() %>%
      clearControls() %>%
      addPolygons(color = "#b2aeae", # you need to use hex colors
                  fillColor = pal((merged_df %>% select(cause))[[1]]),
                  fillOpacity = 0.7,
                  weight = 1,
                  smoothFactor = 0.2,
                  popup = popup) %>%
      addLegend(pal = pal,
                values = (merged_df %>% select(cause))[[1]],
                position = "bottomright",
                title = "Mortality per 100,000 persons")
  })
  
  # Show data using DataTable
  output$table <- DT::renderDataTable({
    datatable(merged_df, rownames=FALSE) %>% 
      formatStyle(input$selected, background="skyblue", fontWeight='bold')
  })

  # Show statistics using infoBox
  output$maxBox <- renderInfoBox({
    max_value <- 
      max(merged_df %>% select(input$selected) %>% st_set_geometry(NULL))
    max_state <-
      merged_df$state_name[merged_df 
                           %>% select(input$selected) %>% 
                             st_set_geometry(NULL) == max_value] 
    max_county <-
      merged_df$location_name[merged_df %>% 
                                select(input$selected) %>% 
                                st_set_geometry(NULL) == max_value]
    infoBox(title = max_state, 
            value = round(max_value, digits=3),
            subtitle = max_county,
            icon = icon("hand-o-up"))
  })
  output$minBox <- renderInfoBox({
    min_value <- 
      min(merged_df %>% select(input$selected) %>% st_set_geometry(NULL))
    min_state <-
      merged_df$state_name[merged_df %>% 
                                select(input$selected) %>% 
                                st_set_geometry(NULL) == min_value]
    min_county <-
      merged_df$location_name[merged_df %>% 
                                select(input$selected) %>% 
                                st_set_geometry(NULL) == min_value]
    infoBox(title = min_state,
            value = round(min_value, digits=3),
            subtitle = min_county, 
            icon = icon("hand-o-down"))
  })
  output$avgBox <- renderInfoBox(
    infoBox(paste("AVG.", input$selected),
            round(mean((merged_df %>% 
                          select(input$selected) %>% 
                          st_set_geometry(NULL))[[1]]), digits=3), 
            icon = icon("calculator"), fill = TRUE))

})
