library(shiny)
library(shinydashboard)
library(plotly)
library(magrittr)
load("data/PAD_DATA.rda")

PAD_DATA[, SERVICE_PER_100KPY := PSPS_SUBMITTED_SERVICE_CNT / ENROLLMENT * 1e6]


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
                                 plot_ly(PAD_DATA[,
                                                  .(Total = sum(PSPS_SUBMITTED_SERVICE_CNT),
                                                    TP100KPY = sum(SERVICE_PER_100KPY)),
                                                  by = YEAR],
                                         x = ~ YEAR) %>%
                                 add_trace(y = ~ Total, name = "Total Submitted Services", type = "scatter", mode = "lines+markers") %>%
                                 add_trace(y = ~ TP100KPY, name = "Total Submitted Services per 100KPY", type = "scatter", mode = "lines+markers", yaxis = "y2") %>%
                                 layout(yaxis2 = list(title = "Services per 100KPY", overlaying = "y", side = "right"))
                                )
  }

shinyApp(ui, server)

