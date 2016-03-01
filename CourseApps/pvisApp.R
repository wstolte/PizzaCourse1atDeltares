#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readr)
library(ggplot2)
library(rworldmap)
library(scales)

## preparatory code, to make the app work smooth. Time consuming code that does not
## have to be responsive belongs here. 
url <- "http://marineprojects.openearth.nl/geoserver/mep-nsw/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=mep-nsw:mep-nsw_pvis&outputFormat=csv"
pvis <- read_csv(url, col_types = "__cdd_____c____c_c_________d__")
pvisAantal <- pvis[pvis$Parameter.omschrijving == "Aantal",] # unique locations
pvisAantal$datum <- as.Date(pvisAantal$monsternemingsdatum) 
pvisAantal$jaar <- format(pvisAantal$datum, format = "%Y")

## Define bounding box for geographical data (20 % extended on all sides)
xxlim <- expand_range(c(min(pvis$GeometriePunt.x), max(pvis$GeometriePunt.x)), mul = 0.4)
yylim <- expand_range(c(min(pvis$GeometriePunt.y), max(pvis$GeometriePunt.y)), mul = 0.2)

## load low res worldmap data from package rworldmap
data(countriesLow)
## convert into dataframe for plotting in ggplot (ggplot2 function)
world <- fortify(countriesLow)
## make ggplot object with the map background (same for all plots, so belongs here)
map <- ggplot() +
  geom_polygon(data = world, 
               aes(x=long, y=lat, group=group), 
               color = "lightgrey", 
               fill = "darkgrey") +
  coord_quickmap(xlim = xxlim, ylim = yylim)



# Define UI for application that draws a map of fish numbers
#=================================================================
ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("Pelagic Fish Data NSW"),
  
  # Sidebar with a dropdown box for input 
  sidebarLayout(
    sidebarPanel(
      selectInput("species",
                  "Species:",
                  unique(pvisAantal$organisme.naam), 
                  selected = "Clupea harengus"
      ),
      selectInput("year",
                  "Year:",
                  unique(pvisAantal$jaar)
      )
    ),
    # Show a map plot
    mainPanel(
      plotOutput("mapPlot",  width = "100%")
    )
  )
))

# Define server logic required to draw a histogram
#================================================================
server <- shinyServer(function(input, output) {
  output$mapPlot <- renderPlot({
    ## all the code in renderPlot function is responsive i.e. the code is run 
    ## each time the UI input affecting this code is changed
    
    ## select the species chosen in the user interface    
    pvis_selected <- pvisAantal[pvisAantal$organisme.naam == input$species & pvisAantal$jaar == input$year,]
    ## Use the ggplot map object defined earlier
    map +
      geom_point(data = pvis_selected, 
                 aes(GeometriePunt.x, GeometriePunt.y, size = Numeriekewaarde)) + 
      # geom_text(data = pvis_selected, aes(GeometriePunt.x, GeometriePunt.y, label = Metingomschrijving)) +
      annotate("text", x = 4.4129,y = 52.5921, label = "NSW", color = "orange", size = 8) 
  })
})

# Run the application 
#=================================================================
shinyApp(ui = ui, server = server)

