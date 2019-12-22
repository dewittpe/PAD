library(shiny)
library(shinydashboard)
library(plotly)
library(magrittr)
load("data/PAD_DATA.rda")

PAD_DATA[, SERVICE_PER_100KPY := PSPS_SUBMITTED_SERVICE_CNT / ENROLLMENT * 1e6]


ui <-
  dashboardPage(
                dashboardHeader(title = "PAD")#h4(HTML("Trends in Endovascular<br>Peripheral Artery Disease<br>Interventions for the Medicare Population")))
                , dashboardSidebar(
                                   radioButtons("yaxes", "Y-Axis",
                                                c("Total Submitted Services Only" = 1,
                                                  "Submitted Services per 100KPY Only" = 2,
                                                  "Both" = 3))
                                  )
                , dashboardBody(
                                plotlyOutput("plot1")
                               )
               )

server <-
  function(input, output) {

    reactiveData <- reactive({
      PAD_DATA[,
               .(Total = sum(PSPS_SUBMITTED_SERVICE_CNT),
                 TP100KPY = sum(SERVICE_PER_100KPY)),
                             by = YEAR]
    })


    output$plot1 <- renderPlotly(
                                 {
                                   plotting_data <- reactiveData()
                                   pad_plot <- plot_ly(plotting_data, x = ~ YEAR)

                                   if (input$yaxes == 1) {
                                     pad_plot %<>%
                                       add_trace(y = ~ Total, name = "Total Submitted Services", type = "scatter", mode = "lines+markers")
                                   } else if (input$yaxes == 2) {
                                     pad_plot %<>%
                                       add_trace(y = ~ TP100KPY, name = "Total Submitted Services per 100KPY", type = "scatter", mode = "lines+markers")
                                   } else {
                                     pad_plot %<>%
                                       add_trace(y = ~ Total, name = "Total Submitted Services", type = "scatter", mode = "lines+markers") %>%
                                       add_trace(y = ~ TP100KPY, name = "Total Submitted Services per 100KPY", type = "scatter", mode = "lines+markers", yaxis = "y2") %>%
                                       layout(yaxis2 = list(title = "Services per 100KPY", overlaying = "y", side = "right"))
                                   }
                                   pad_plot
                                 }
    )
  }

shinyApp(ui, server)

