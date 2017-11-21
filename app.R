
library(shiny)
library(keras)
library(stringr)
library(readr)
library(purrr)
library(tokenizers)

source('get_trained_models.R')

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
                                 fluidRow(
                                   "Leading text to generate output (upto 40 characters, more text is better)",
                                   column(6,
                                          textInput("init_text",
                                                    "")
                                          ),
                                   column(2,
                                          actionButton("generate", "Generate Text")
                                          )
                                   ),
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
                            pre(id = "console"),
                            textOutput("model_architecture")
                          )
                        )
                        )
   ))

)

server <- function(input, output) {
  trained_models <- get_trained_models()
  speaker <- as.character(trained_models[,1])
  output$choose_speaker <- renderUI({
    selectInput("speaker", "Speaker ", speaker)
  })
  
  observeEvent(input$generate, {
    source('get_next_text.R')
    output$next_text <- renderText(
      get_next_text(input$speaker, input$init_text, input$diversity, trained_models)
    )
  })
  
  
  

  observeEvent(input$setup_training, {
    # run only when action button is on. 

    source('training.R')
    training_setup(input$file1$datapath)
    })


}

# Run the application 
shinyApp(ui = ui, server = server)

