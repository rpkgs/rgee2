library(shiny)
library(leaflet)

library(rgee)
rgee::ee_Initialize()

sf_prov = ee$FeatureCollection("users/kongdd/shp/China/bou2_4p_ChinaProvince")
ee_draw_sf <- function(shp, title = NULL, color = '000000', width=1.5) {
  empty = ee$Image()$byte()
  if (is.null(title)) title = shp$get("system:id") %>% getInfo() %>% basename()
  # Paint all the polygon edges with the same number and width, display.
  outline = empty$paint(featureCollection = shp, color = 1, width = width)
  Map$addLayer(outline, list(palette = color), title)
}

dates = 1:10

ui <- fluidPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),

  selectInput("date",
    label = "Date",
    choices = dates, selected = dates[length(dates)]
  ),
  actionButton("recalc", "Add SRTM Global Map"),
  leafletOutput("mymap"),
)

server <- function(input, output, session) {
  output$mymap <- renderLeaflet({
    m1 = Map$addLayer(ee$Image("srtm90_v4"), list(min = 0, max = 1000)) + 
      ee_draw_sf(sf_prov, "prov")
    m2 = Map$addLayer(ee$Image("srtm90_v4"), list(min = 0, max = 1000)) + 
      ee_draw_sf(sf_prov, "prov")
    
    library(leaflet.minicharts)
    library(manipulateWidget)
    m <- combineWidgets(m1, m2)
    m
  })
  
  # observe({
  #   proxy <- leafletProxy("mymap")
  #   # Remove any existing legend, and only if the legend is
  #   # enabled, create a new one.
  #   if (input$recalc) {
  #     print("click")
  #     proxy %>%
  #       # clearImages()
  #       # clearControls()
  #       clearGroup("srtm90_v4")
  #     proxy + Map$addLayer(ee$Image("srtm90_v4"), list(min = 0, max = 1000))
  #   }
  # })
}
shinyApp(ui = ui, server = server)
