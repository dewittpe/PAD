library(shiny)
library(shinydashboard)
library(plotly)
library(magrittr)
library(data.table)
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
                                plotlyOutput("plot1"),
                                plotlyOutput("plot2")
                               )
               )

server <-
  function(input, output) {

    reactiveData <- reactive({
      totals <- PAD_DATA[, .(Total = sum(PSPS_SUBMITTED_SERVICE_CNT), TP100KPY = sum(SERVICE_PER_100KPY)), by = YEAR]

      totals <- totals[order(YEAR)]
      totals[, `:=`(
                    Total_PCPY      = (Total / shift(Total) -1),
                    Total_PC2011    = (Total / Total[.I == 1] - 1),
                    TP100KPY_PCPY   = (TP100KPY / shift(TP100KPY) -1),
                    TP100KPY_PC2011 = (TP100KPY / TP100KPY[.I == 1] - 1)
                   )]
      totals

    })


    output$plot1 <- renderPlotly({
      plotting_data <- reactiveData()
      pad_plot <- plot_ly(plotting_data, x = ~ YEAR)

      if (input$yaxes == 1) {
        pad_plot %<>%
          add_trace(y = ~ Total, name = "Total Submitted Services", type = "scatter", mode = "lines+markers", line = list(dash = "dash"))
      } else if (input$yaxes == 2) {
        pad_plot %<>%
          add_trace(y = ~ TP100KPY, name = "Total Submitted Services per 100KPY", type = "scatter", mode = "lines+markers")
      } else {
        pad_plot %<>%
          add_trace(y = ~ Total, name = "Total Submitted Services", type = "scatter", mode = "lines+markers", line = list(dash = "dash")) %>%
          add_trace(y = ~ TP100KPY, name = "Total Submitted Services per 100KPY", type = "scatter", mode = "lines+markers", yaxis = "y2") %>%
          layout(yaxis2 = list(title = "Services per 100KPY", overlaying = "y", side = "right", color = "orange"))
      }
      pad_plot %<>% layout(legend = list(orientation = "h"))
      pad_plot
    })

    output$plot2 <- renderPlotly({
      plotting_data <- reactiveData()
      print(plotting_data)
      pad_plot <- plot_ly(plotting_data, x = ~ YEAR)

      if (input$yaxes == 1) {
        pad_plot %<>% add_trace(y = ~ Total_PCPY, name = "Percent Change from Prior Year of Total Procedures", type = "scatter", mode = "lines+markers", line = list(dash = "dash"))
        pad_plot %<>% add_trace(y = ~ Total_PC2011, name = "Percent Change from 2011 of Total Procedures", type = "scatter", mode = "lines+markers", line = list(dash = "dash"))
      } else if (input$yaxes == 2) {
        pad_plot %<>% add_trace(y = ~ TP100KPY_PCPY, name = "Percent Change from Prior Year of Procedures per 100KPY", type = "scatter", mode = "lines+markers")
        pad_plot %<>% add_trace(y = ~ TP100KPY_PC2011, name = "Percent Change from 2011 of Procedures per 100KPY", type = "scatter", mode = "lines+markers")
      } else {
        pad_plot %<>% add_trace(y = ~ Total_PCPY, name = "Percent Change from Prior Year of Total Procedures", type = "scatter", mode = "lines+markers", line = list(dash = "dash"))
        pad_plot %<>% add_trace(y = ~ Total_PC2011, name = "Percent Change from 2011 of Total Procedures", type = "scatter", mode = "lines+markers", line = list(dash = "dash"))
        pad_plot %<>% add_trace(y = ~ TP100KPY_PCPY, name = "Percent Change from Prior Year of Procedures per 100KPY", type = "scatter", mode = "lines+markers")
        pad_plot %<>% add_trace(y = ~ TP100KPY_PC2011, name = "Percent Change from 2011 of Procedures per 100KPY", type = "scatter", mode = "lines+markers")
      }

      pad_plot %<>%  layout(yaxis = list(tickformat = ',.0%'), legend = list(orientation = "h"))
      pad_plot
                                 })
  }

shinyApp(ui, server)

