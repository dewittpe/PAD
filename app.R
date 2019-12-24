library(shiny)
library(shinydashboard)
library(plotly)
library(magrittr)
library(data.table)
load("data/PAD_DATA.rda")

PAD_DATA[, SERVICE_PER_100KPY := PSPS_SUBMITTED_SERVICE_CNT / ENROLLMENT * 1e6]

ui <- #{{{
  dashboardPage(
                dashboardHeader(title = "PAD")#h4(HTML("Trends in Endovascular<br>Peripheral Artery Disease<br>Interventions for the Medicare Population")))
                , dashboardSidebar(
                                   radioButtons("yaxes", "Y-Axis",
                                                c("Total Submitted Services Only" = 1,
                                                  "Submitted Services per 100KPY Only" = 2,
                                                  "Both" = 3))
                                  )
                , dashboardBody(
                                fluidRow(
                                         box(title = "Total Services", width = 6, plotlyOutput("plot1"))
                                         ,
                                         box(title = "Total Services per 100,000 Person Years", width = 6, plotlyOutput("plot3"))
                                         )
                                ,
                                fluidRow(
                                         box(title = "Percent Change in Total Services", width = 6, plotlyOutput("plot2"))
                                         ,
                                         box(title = "Percent Change in Services per 100,000 Person Years", width = 6, plotlyOutput("plot4"))
                                         )
                               )
               )
#}}}

server <-
  function(input, output) {

    reactiveData <- reactive({# {{{
      totals <- PAD_DATA[, .(Total = sum(PSPS_SUBMITTED_SERVICE_CNT), TP100KPY = sum(SERVICE_PER_100KPY)), by = YEAR]

      totals <- totals[order(YEAR)]
      totals[, `:=`(
                    Total_PCPY      = (Total / shift(Total) -1),
                    Total_PC2011    = (Total / Total[.I == 1] - 1),
                    TP100KPY_PCPY   = (TP100KPY / shift(TP100KPY) -1),
                    TP100KPY_PC2011 = (TP100KPY / TP100KPY[.I == 1] - 1)
                   )]
      totals

    })# }}}

    output$plot1 <- renderPlotly({# {{{
      plotting_data <- reactiveData()
      pad_plot <- plot_ly(plotting_data, x = ~ YEAR)

      pad_plot %<>%
        add_trace(y = ~ Total, name = "Total Submitted Services", type = "scatter", mode = "lines+markers")

      pad_plot %<>% layout(legend = list(orientation = "h"))
      pad_plot
    })# }}}

    output$plot2 <- renderPlotly({# {{{
      plotting_data <- reactiveData()
      pad_plot <- plot_ly(plotting_data, x = ~ YEAR)
      pad_plot %<>% add_trace(y = ~ Total_PC2011, name = "since 2011",      type = "scatter", mode = "lines+markers")
      pad_plot %<>% add_trace(y = ~ Total_PCPY,   name = "from prior year", type = "scatter", mode = "lines+markers", line = list(dash = "dot"))
      pad_plot %<>%  layout(yaxis = list(tickformat = ',.0%'), legend = list(orientation = "h"))
      pad_plot
                                 })# }}}

    output$plot3 <- renderPlotly({# {{{
      plotting_data <- reactiveData()
      plot_ly(plotting_data, x = ~ YEAR, y = ~ TP100KPY) %>% add_trace(type = "scatter", mode = "lines+markers")
    })# }}}

    output$plot4 <- renderPlotly({# {{{
      plotting_data <- reactiveData()
      plot_ly(plotting_data, x = ~ YEAR, y = ~ TP100KPY_PCPY) %>%
        add_trace(y = ~ TP100KPY_PC2011, name = "from 2011",       type = "scatter", mode = "lines+markers") %>%
        add_trace(y = ~ TP100KPY_PCPY,   name = "from prior year", type = "scatter", mode = "lines+markers", line = list(dash = "dot")) %>%
        layout(yaxis = list(tickformat = ',.2%'), legend = list(orientation = "h"))
    })# }}}
  }

shinyApp(ui, server)

