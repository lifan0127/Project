# server.R

# From here, start to use boston_rev.csv file
boston <- read.csv("data/boston_rev.csv", stringsAsFactors=FALSE)
boston$TRACT <- as.factor(boston$TRACT)
boston$CHAS <- as.factor(boston$CHAS)


# Linear Regression Model
#library(caTools)
#set.seed(123)
#split <- sample.split(boston$MEDV, 0.7)
#train <- subset(boston, split==TRUE)
#test <- subset(boston, split==FALSE)

# lm.model <- lm(MEDV ~ TOWN + CHAS + RM + AGE, data=train)
# lm.pred <- predict(lm.model, newdata=test)
# sum((lm.pred - test$MEDV)^2)  # SSE = 3676.374


# Linear Regression Model - Final
lm.model <- lm(MEDV ~ TOWN + CHAS + RM + AGE, data=boston)


# Example
predict(lm.model, newdata=data.frame(TOWN="Marblehead", CHAS=factor(0), RM=3, AGE=20))  # Price = USD 9.47 k 


# Create Map Visualization
library(maps)
library(mapproj)
library(maptools)
library(rgeos)
library(sp)
library(ggplot2)
library(ggmap)

# Prepare MA shape file
shapefile <- readShapeSpatial("data/tl_2010_25_county10.shp",
                              proj4string = CRS("+proj=longlat +datum=WGS84"))
data <- fortify(shapefile)

massachusetts <- get_googlemap(center = c(-71.1553, 42.3512), zoom = 9, scale=2,
                               maptype="terrain", size=c(640, 640), filename = "www/ggmapTemp",
                               style="feature:all|element:labels|visibility:off&style=feature:road|visibility:off&style=feature:poi|visibility:off")

# Construct ggmap
# g.map <- ggmap(massachusetts) + 
#  geom_path(aes(x=long, y=lat, group=group), data=data, colour="#ABABAB", size =1) +
#  coord_cartesian(xlim=c(-71.5, -70.8), ylim=c(42.2, 42.5)) +
#  theme(line = element_blank(),
#        text = element_blank(),
#        line = element_blank(),
#        title = element_blank())

g.map <- ggmap(massachusetts) + 
  geom_path(aes(x=long, y=lat, group=group), data=data, colour="#ABABAB", size =1) +
  coord_cartesian(xlim=c(-71.9, -70.6), ylim=c(42.0, 42.7)) +
  theme(line = element_blank(),
        text = element_blank(),
        line = element_blank(),
        title = element_blank())


shinyServer(
  function(input, output) {
    PickTown <- reactive({
      towns = unique(boston$TOWN[boston$COUNTY==input$County]) 
      return(towns)
    })
    
    HouseDescription <- reactive({
      river <- ifelse(input$Charles=="1", " near the Charles River.", ".")
      sen1 <- paste0("The house was located in ", input$Town, ", ", input$County, river)
      sen2 <- paste0("The house had ", input$Room, " rooms, and was roughly ", input$Age, " years old.")
      return(paste(sen1, sen2))
    })
    
    PriceEstimation <- reactive({
      price <- predict(lm.model, newdata=data.frame(TOWN=input$Town, 
                                                    CHAS=factor(input$Charles), 
                                                    RM=input$Room, 
                                                    AGE=input$Age))
      #print(price)
      return(paste("$ ", round(price*1000), "USD"))
    })
    
    LoadMap <- reactive({
      print(input$Town)
      town.index <- which(boston$TOWN == input$Town)[1]
      print(boston[town.index, ])
      
      g.map <- g.map +   
                   geom_point(data=boston[town.index, ], aes(x=LON, y=LAT), color="red", size=4) +
                   annotate("text", x = boston[town.index, "LON"], y = boston[town.index, "LAT"]+0.036, label = boston[town.index, "TOWN"], size=7) +
                   annotate("text", x = boston[town.index, "LON"], y = boston[town.index, "LAT"]+0.014, label = paste(boston[town.index, "COUNTY"], "County"), size=4)
      return(g.map)
    })

    output$Town = renderUI({
      selectInput("Town", 
                  label = "In which town?",
                  choices = PickTown(),
                  selected = PickTown()[1])
    })

    output$Map <- renderPlot({
      if (!is.null(input$Town)){
        LoadMap()
      }
    })
    
    output$Summary <- renderText({ 
      if (!is.null(input$Town)){
        HouseDescription()
      }
    })
    output$Price <- renderText({ 
      if (!is.null(input$Town)){
        PriceEstimation()
      }
    })    
  }
)