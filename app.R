
library(shiny)
library(keras)
library(stringr)
library(readr)
library(purrr)
library(tokenizers)


# Define UI for application 
ui <- fluidPage(
  theme = shinythemes::shinytheme("cosmo"),
  img(src='speech.jpeg', align = "center", width="100%"),
  
   # Application title
   #titlePanel("Just a Minute"),
   shinyUI(navbarPage("Just a Minute",
                      tabPanel("Predict Speech",
                               sidebarPanel(
                                 uiOutput("choose_speaker"),
                                 sliderInput("diversity", "Diversity",
                                                        min = .2, max = 1.5, value = 1)
                               ),
                               mainPanel(
                                 fluidRow(textInput("init_text", 
                                                    "Leading text to generate output (upto 40 characters, more text is better)")),
                                 fluidRow(verbatimTextOutput("next_text"))
                                 
                               )
                      ),
                      tabPanel(
                        "Train LSTM",
                        tags$h2("Training a LSTM for Speech/Writing Prediction"),
                        fluidRow(
                          column(
                            4,
                            tags$h3("Upload Speech or Writing for training"),
                            fileInput("file1", "Choose File"),
                            actionButton("setup_training", "Setup Training")
                          ),
                          column(
                            8,
                            tags$h3("LSTM will be trained with predefined architecture. To modify the architecture please fork"),
                            textOutput("model_architecture")
                          )
                        )
                        )
   ))

)

server <- function(input, output) {
  speaker <- c("Friedrich Nietzsche","Donald Trump")
  output$choose_speaker <- renderUI({
    selectInput("speaker", "Speaker ", speaker)
  })
  source('get_next_text.R')
  output$next_text <- renderText(get_next_text(input$init_text, input$diversity))
  
  observeEvent(input$setup_training, {
    # run only when setup is clicked

    source('training.R')
    
    withCallingHandlers(
      training_setup(input$file1$datapath),
      message = function(m) output$model_architecture <- renderPrint(m$message)
    )


  })

}

# Run the application 
shinyApp(ui = ui, server = server)

