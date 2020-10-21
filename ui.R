
fluidPage(leafletjs, dashboardPage(
  skin = "black",
  dashboardHeader(title = "Mortality",
                  dropdownMenu(type = "notifications",
                               notificationItem(
                                 text = "You Will Die.",
                                 icon = icon("exclamation-triangle"),
                                 status = "warning"))),
  dashboardSidebar(
    selectizeInput("main",
                   "Cause of Mortality",
                   choice,
                   selected = "All causes"),    
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database")),
      menuItem("Chart", tabName = "charts", icon = icon("chart-bar")),
      menuItem("Trends", tabName = "trends", icon = icon("chart-line")),
      menuItem("About Me", tabName = "aboutme", icon = icon("grin-beam")),
      menuItem("Download", tabName = "download", icon = icon("download"))
    )
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
              fluidRow(box(DT::dataTableOutput("table", height = 900), width = 12))),
      tabItem(tabName = "charts",
              fluidRow(box(
                plotOutput("bars", height = 900),
                width = 12))),
      tabItem(tabName = "trends",
              fluidRow(box(
                plotOutput("line1"),
                br(),
                selectizeInput("states_chooser",
                               "States",
                               states$state_name,
                               selected = "New York",
                               multiple = TRUE),
                br(),
                plotOutput("line2"),
                br(),
                plotOutput("line3", height = 700),
                br(),
                selectizeInput("death_chooser",
                               "Cause of Mortality",
                               choice,
                               multiple = TRUE),
                width = 12
              ))),
      tabItem(tabName = "aboutme",
              fluidRow(box(
                title = "Tyrone R. Wilkinson",
                status = "primary",
                solidHeader = TRUE,
                img(
                  src = "my_pic.jpg",
                  height = "200px"),
                br(),
                tags$em("Venit Mors Velocitor"),
                br(),
                "tyronerwilkinson@gmail.com",
                br(),
                tags$a(
                  href = "https://www.linkedin.com/in/tyronewilkinson/",
                  img(
                    src = "LinkedIn_Icon.svg",
                    title = "My LinkedIn",
                    height = "50px"
                  )
                ),
                tags$a(
                  href = "https://github.com/TyroneWilkinson/Mortality/",
                  img(
                    src = "GitHub_Icon.png",
                    title = "My GitHub",
                    height = "50px"
                  )
                ),
                
              ))),
      tabItem(tabName = "download",
              fluidRow(box(
                title = "Mortality Data" ,
                status = "primary",
                solidHeader = TRUE,
                tags$a(
                  href = "http://ghdx.healthdata.org/record/ihme-data/united-states-mortality-rates-county-1980-2014",
                  "Global Health Data Exchange"
                )
              ))
      )
    )
  )
))
