
library(shiny)
library(keras)
library(stringr)
# Define UI for application 
ui <- fluidPage(
  theme = shinythemes::shinytheme("cosmo"),
  img(src='speech.jpeg', align = "center", width="100%"),
  
   # Application title
   #titlePanel("Just a Minute"),
   
   shinyUI(navbarPage("Just a Minute",
                      tabPanel("Predict Speech",
                               sidebarPanel(selectInput("speaker", "Speaker ",
                                                        c("Friedrich Nietzsche",
                                                          "Donald Trump"
                                                          )
                                                        )
                                            ),
                               mainPanel(
                                 fluidRow(textInput("init_text", 
                                                    "Leading text to generate output")),
                                 fluidRow(verbatimTextOutput("next_text"))
                                 
                               )
                      ),
                      tabPanel("Train LSTM")
   ))

)

# Define server logic required to draw a histogram
server <- function(input, output) {
  source('get_next_text.R')
  output$next_text <- renderText(get_next_text(input$init_text))

}

# Run the application 
shinyApp(ui = ui, server = server)

