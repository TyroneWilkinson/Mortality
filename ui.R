library(DT)
library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "DEATHS"),
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database"))
    ),
    selectizeInput("selected",
                   "Select Item to Display",
                   choice)
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
              fluidRow(box(htmlOutput("map"), height = 300))),
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), width = 12)))
    )
  )
))