
library(shiny)
library(keras)
library(stringr)
library(readr)
library(purrr)
library(tokenizers)
library(shinyjs)
library(Rtts)
source('get_trained_models.R')
source('get_next_text.R')

# Define UI for application 
ui <- fluidPage(
  
  theme = shinythemes::shinytheme("cosmo"),
  img(src='speech.jpeg', align = "center", width="100%"),
  
   # Application title
   #titlePanel("Just a Minute"),
   shinyUI(navbarPage("Just a Minute",
                      tabPanel("Predict Speech",
                               useShinyjs(),
                               sidebarPanel(
                                 uiOutput("choose_speaker"),
                                 sliderInput("diversity", "Diversity",
                                                        min = .2, max = 1.5, value = .2)
                               ),
                               mainPanel(
                                 fluidRow(
                                   tags$h3(
                                     "Leading text to generate output"
                                     ),
                                   column(9,
                                          textInput("init_text",
                                                    "",
                                                    placeholder = "upto 40 characters")
                                          ),
                                   column(2,
                                          tags$br(),
                                          actionButton("generate", "Generate Text")
                                          )
                                   ),
                                 fluidRow(
                                   column(9,
                                          #verbatimTextOutput("next_text", placeholder = TRUE)
                                          tags$h4(paste("Thus spake ...")),
                                          textOutput("next_text")
                                   ),
                                   column(2,
                                          shinyjs::hidden(
                                          actionButton("listen", "", icon = icon("music"))
                                          )
                                   )
                                 ),
                                 fluidRow(
                                   uiOutput("audiotag")
                                 )

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
  txt <- ""
  trained_models <- get_trained_models()
  speaker <- as.character(trained_models[,1])
  output$choose_speaker <- renderUI({
    selectInput("speaker", "Speaker ", speaker)
  })
  
  observeEvent(input$generate, {
    shinyjs::hide("audiotag")
    # Create a Progress object
    shinyjs::hide("listen")
    updateProgress <- function(value = NULL, detail = NULL) {
      if (is.null(value)) {
        value <- progress$getValue()
        value <- value + (progress$getMax() - value) / 5
      }
      progress$set(value = value, detail = detail)
    }
    output$next_text <- renderText({
      progress <- shiny::Progress$new()
      progress$set(message = "Computing Predictive Text", value = .5)
      # Close the progress when this reactive exits (even if there's an error)
      on.exit(progress$close())
      updateProgress <- function(value = NULL, detail = NULL) {
        if (is.null(value)) {
          value <- progress$getValue()
          value <- value + (progress$getMax() - value) / 5
        }
        progress$set(value = value, detail = detail)
      }
      isolate(
        txt <<- get_next_text(input$speaker, input$init_text, input$diversity, trained_models)
      )
      
    })
    shinyjs::show("listen")

  })
  
  observeEvent(input$setup_training, {
    # run only when action button is on. 

    source('training.R')
    training_setup(input$file1$datapath)
    })

  observeEvent(input$listen, {
    shinyjs::hide("audiotag")
    Rtts::tts_ITRI(txt, speaker = "Bruce", destfile = 'www/audio.wav')
    output$audiotag <- renderUI(tags$audio(src = 'audio.wav', type ="audio/wav",
                                           autoplay = TRUE, controls = NA))
    shinyjs::show("audiotag")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

