shinyUI(fluidPage(
  titlePanel("Boston Home Price in 1978"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("This app estimates Boston home price in 1978 based on 
               linear regressiong model."),

      selectInput("County", 
                  label = "Which county was the house located in?",
                  choices = c("Essex", "Middlesex", "Norfolk", "Plymouth", "Suffolk"),
                  selected = "Essex"),
      
      uiOutput('Town'),
      
      radioButtons("Charles", 
                   label = ("Was it next to Charles River?"),
                   choices = list("Yes" = 1, "No" = 0), 
                   selected = 0),
      
      sliderInput("Room", 
                  label = "How many rooms it had?",
                  min = 4, max = 10, value = 7),
      
      sliderInput("Age", 
                  label = "How old was the house in 1978?",
                  min = 1, max = 100, value = 50)
      ),
    
    mainPanel(
      #plotOutput("Map"),
      #textOutput("Summary"),
      #p(""),
      #p("The estimated price in 1978 was"),
      #h4(textOutput("Price"), align = "right"),
      tabsetPanel(
        tabPanel("Result", plotOutput("Map"),
                           textOutput("Summary"),
                           p(""),
                           p("The estimated price in 1978 was"),
                           h4(textOutput("Price"), align = "right")),
        tabPanel("Documentation", includeHTML("www/documentation.html"))
      )
    )
  )
))