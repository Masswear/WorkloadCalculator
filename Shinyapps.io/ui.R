
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(
  shinyjs::useShinyjs(),

  # Application title
  titlePanel("Physical Workload Calculator"),

  # Sidebar with input fields
  sidebarLayout(
    sidebarPanel(
      textInput("location", "Country of origin", "Switzerland"),
      numericInput("MPA",
                   "Moderate physical activity [min/day]",
                   min = 1,
                   max = 50,
                   value = 30,
                   step = 1.0),
      numericInput("HPA",
                   "High physical activity [min/day]",
                   min = 1,
                   max = 50,
                   value = 30,
                   step = 1),
      numericInput("VHPA",
                   "Very high physical activity [min/day]",
                   min = 1,
                   max = 50,
                   value = 30,
                   step = 1),
      selectInput("occupation", 
                  "Occupational Activity",
                  c("Low intensity" = "LI",
                    "Medium intensity" = "MI",
                    "High intensity" = "HI")),
      numericInput("WH",
                   "Working hours [h/day]",
                   min = 1,
                   max = 24,
                   value = 8,
                   step = 0.5),
      checkboxInput("FT",
                    "Flextime",
                    FALSE),
      numericInput("Age",
                   "Age [years]",
                   min = 1,
                   max = 50,
                   value = 30,
                   step = 1),
      numericInput("VO2max",
                   "Maximal oxygen consumption [metabolic equivalents]",
                   min = 1,
                   max = 50,
                   value = 30,
                   step = 1),
      actionButton("submit", "Calculate"),
      # hidden input field tracking the timestamp of the submission
      shinyjs::hidden(textInput("timestamp", ""))
    ),
    

    # Show the calculated workload
    mainPanel(tabsetPanel(type = "tabs", id = "tabs",
                          tabPanel("Background", value = "bg",
                                   includeMarkdown(file.path("text",
                                                             "background.md")),
                                    shinyjs::hidden(
                                      span(id = "submitMsg", "submitting...")
                                    ),
                                    
                                    shinyjs::hidden(
                                      div(id = "error",
                                          div(br(), tags$b("Error: "), span(id = "errorMsg")),
                                          style = "color: red;"
                                      )
                                    ),
                                   includeMarkdown(file.path("text",
                                                             "credits.md"))),
                          tabPanel("Calculate workload", value = "wl",
                                    h3(textOutput("workload")),
                                    shinyjs::hidden(
                                      span(id = "submitMsg2", "submitting...")
                                    ),
                                   div("One MET corresponds to 3.5 ml O2/kg/min"),
                                    
                                    shinyjs::hidden(
                                      div(id = "error2",
                                          div(br(), tags$b("Error: "), span(id = "errorMsg")),
                                          style = "color: red;"
                                      )
                                    )
                                  ), 
                          tabPanel("Summary table", value = "table",
                                   DT::dataTableOutput("responsesTable"))
      

    )
    )
  )
))
