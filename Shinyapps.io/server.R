# This is the server logic for a Shiny web application.
# 
# Please note that this app needs additional files to run properly.
#


library(magrittr)
library(shiny)
library(DT)
library(markdown)

source("storage.R")
source("helpers.R")
source("algorithm.R")

shinyServer(function(input, output, session) {
  # Give an initial value to the timestamp field
  updateTextInput(session, "timestamp", value = get_time_epoch())
  
  #Displey initial output
  output$workload <- renderText({
    "Change information and press \"Calculate\" to calculate workload"
  })
  
  # Enable the Submit button when all mandatory fields are filled out
  observe({
    fields_filled <-
      fields_mandatory %>%
      sapply(function(x) !is.null(input[[x]]) && input[[x]] != "") %>%
      all
    
    shinyjs::toggleState("submit", fields_filled)
  })
  
  
  # Gather all the form inputs
  form_data <- reactive({
    sapply(fields_all, function(x) x = input[[x]])
  })
  
  # When the Submit button is clicked
  observeEvent(input$submit, {
    # Update the timestamp field to be the current time
    updateTextInput(session, "timestamp", value = get_time_epoch())
    
    # change to tab with calculated workload
    updateTabsetPanel(session, "tabs", selected = "wl")
        
    # calculate workload
    new_workload <- calc_workload(input$MPA,
                                  input$HPA,
                                  input$occupation,
                                  input$WH,
                                  input$VHPA,
                       as.numeric(input$FT),
                                  input$Age,
                                  input$VO2max)
    
    
    #update output of workload 
    output$workload <- renderText({
      
      paste("Workload =", new_workload, "METs")
      
    })
  
    # User-experience stuff
    shinyjs::disable("submit")
    shinyjs::show("submitMsg")
    shinyjs::show("submitMsg2")
    shinyjs::hide("error")
    shinyjs::hide("error2")
    on.exit({
      shinyjs::enable("submit")
      shinyjs::hide("submitMsg")
      shinyjs::hide("submitMsg2")
    })
    
    # Save the data (show an error message in case of error)
    tryCatch({
      save_data_gsheets(unlist(c(form_data(), list(workload = new_workload))))
      
    },
    error = function(err) {
      shinyjs::text("errorMsg", err$message)
      shinyjs::show(id = "error", anim = TRUE, animType = "fade")      
      shinyjs::logjs(err)
    })

  
})

# Update the responses whenever a new submission is made or the
# storage type is changed
responses_data <- reactive({
  input$submit
  load_data_gsheets()
})


# Show the responses in a table
output$responsesTable <- DT::renderDataTable(
  DT::datatable(
    responses_data(),
    rownames = FALSE,
    options = list(searching = FALSE, lengthChange = FALSE, scrollX = TRUE)
  )
)

})
