
shinyUI(dashboardPage(
  skin = "black",
  dashboardHeader(title = "Mortality",
                  dropdownMenu(type = "notifications",
                               notificationItem(
                                 text = "You Will Die.",
                                 icon = icon("exclamation-triangle"),
                                 status = "warning"))),
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database"))
    ),
    selectizeInput("selected",
                   "Cause of Mortality",
                   choice,
                   selected = "All causes")
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
      tabItem(tabName = "map",
              fluidRow(infoBoxOutput("maxBox"),
                       infoBoxOutput("minBox"),
                       infoBoxOutput("avgBox")),
              fluidRow(box(leafletOutput("map", height = 900), width = 12))),
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), width = 12)))
    )
  )
))
