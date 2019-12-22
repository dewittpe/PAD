library(shiny)
library(shinydashboard)
library(plotly)
library(magrittr)
load("data/PAD_DATA.rda")

ui <-
  dashboardPage(
                dashboardHeader(title = "PAD")#h4(HTML("Trends in Endovascular<br>Peripheral Artery Disease<br>Interventions for the Medicare Population")))
                , dashboardSidebar()
                , dashboardBody(
                                plotlyOutput("plot1")
                               )
               )

server <-
  function(input, output) {
    output$plot1 <- renderPlotly(
                                 plot_ly(PAD_DATA[, .(`Total Procedures` = sum(PSPS_SUBMITTED_SERVICE_CNT)), by = YEAR],
                                         x = ~ YEAR,
                                         y = ~ `Total Procedures`) %>%
                                 add_trace( mode = "lines+markers")
                                )
  }

shinyApp(ui, server)

