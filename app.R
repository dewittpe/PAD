library(shiny)
library(shinydashboard)
library(plotly)
library(magrittr)
library(data.table)
load("data/PAD_DATA.rda")

PAD_DATA[, SERVICE_PER_100KPY := PSPS_SUBMITTED_SERVICE_CNT / ENROLLMENT * 1e6]
PROVIDER_GRP_LVLS         <- c("All Providers", "Cardiology", "Surgery", "Radiology", "Other")
ANATOMIC_SEGMENT_LVLS     <- c("All Segements", "Iliac", "Femoral/Popliteal", "Tibial/Peroneal")
PLACE_OF_SERVICE_GRP_LVLS <- c("All Locations", "Inpatient Hospital", "Outpatient Hospital", "Office", "Ambulatory Clinic", "Ambulatory Surgical Center", "Emergency Room", "Other")
prvd_grp_levels <-# {{{
  c("All Providers",
    "Surgery",
    "Cardiology",
    "Radiology",
    "Other",
    "Femoral/Popliteal",
    "Iliac",
    "Tibial/Peroneal",
    "Inpatient Hospital",
    "Outpatient Hospital",
    "Office"
  )# }}}

pad_colors <-# {{{
  c("Surgery"             = "#e31a1c", #"#e41a1c",
    "Cardiology"          = "#1f78b4", #"#377eb8",
    "Radiology"           = "#33a02c", #"#4daf4a",
    "Other"               = "#6a3d9a", #"#984ea3",
    "All Providers"       = "#ffff99", #"#ff7f00",
    "Femoral/Popliteal"   = "#cab2d6",
    "Iliac"               = "#a6cee3",
    "Tibial/Peroneal"     = "#b2df8a",
    "Inpatient Hospital"  = "#fdbf6f",
    "Outpatient Hospital" = "#fb9a99",
    "Office"              = "#ff7f00"
  )# }}}

pad_shapes <-# {{{
  c("All Providers"       = 1,
    "Surgery"             = 2,
    "Cardiology"          = 3,
    "Radiology"           = 4,
    "Other"               = 5,
    "Femoral/Popliteal"   = 6,
    "Iliac"               = 7,
    "Tibial/Peroneal"     = 8,
    "Inpatient Hospital"  = 9,
    "Outpatient Hospital" = 10,
    "Office"              = 12
  )# }}}

ui <- #{{{
  dashboardPage(
                dashboardHeader(title = "PAD")#h4(HTML("Trends in Endovascular<br>Peripheral Artery Disease<br>Interventions for the Medicare Population")))
                , dashboardSidebar(# {{{
                   sidebarMenu(
                       id = "sidebar"
                     , menuItem("Overview",       tabName = "Overview", icon = icon("fas fa-home"))
                     , menuItem("Data and Plots", tabName = "plots",    icon = icon("fas fa-chart-line"))
                     , conditionalPanel(
                          condition = "input.sidebar == 'plots'"
                        , selectInput("providers", "Providers", c("All Providers" = 1, "By Provider Group" = 2))
                        , conditionalPanel(
                            condition = "input.providers == 2"
                            , checkboxGroupInput("provider_grp", "Provider Group", choices = PROVIDER_GRP_LVLS[-1], selected = PROVIDER_GRP_LVLS[-1]))
                        , selectInput("anatomic", "Anatomic Segment", c("All Sections" = 1, "By Anatomic Segment" = 2))
                        , conditionalPanel(
                            condition = "input.anatomic == 2"
                            , checkboxGroupInput("anatomic_segment", "Anatomic Segment", choices = ANATOMIC_SEGMENT_LVLS[-1], selected = ANATOMIC_SEGMENT_LVLS[-1]))
                        , selectInput("place_of_service", "Place of Service", c("All Locations" = 1, "By Location" = 2))
                        , conditionalPanel(
                                           condition = "input.place_of_service == 2"
                                           , checkboxGroupInput("place_of_service_grp", "Place of Service", choices = PLACE_OF_SERVICE_GRP_LVLS[-1], selected = PLACE_OF_SERVICE_GRP_LVLS[-1]))
                       ) # end of the primary conditionalPanel
                     )
                ) # }}}
                , dashboardBody(# {{{
                                tabItems(tabItem(tabName = "Overview", includeMarkdown("overview.md")),
                                tabItem(tabName = "plots",
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
                                 ) # end of tabName = "plots"
                                )
                )# }}}
               )
#}}}

server <-
  function(input, output) {

    reactiveData <- reactive({# {{{

      BY <- c("YEAR")

      if (input$providers == 2) {
        BY <- c(BY, "PROVIDER_GRP")
      }

      if (input$anatomic == 2) {
        BY <- c(BY, "ANATOMIC_SEGMENT")
      }

      if (input$place_of_service == 2) {
        BY <- c(BY, "PLACE_OF_SERVICE_GRP")
      }

      totals <- PAD_DATA[, .(Total = sum(PSPS_SUBMITTED_SERVICE_CNT), TP100KPY = sum(SERVICE_PER_100KPY)), by = BY]

      setorderv(totals, rev(BY))

      totals[,
             `:=`(
                  Total_PCPY      = (Total / shift(Total) -1),
                  Total_PC2011    = (Total / Total[.I == min(.I)] - 1),
                  TP100KPY_PCPY   = (TP100KPY / shift(TP100KPY) -1),
                  TP100KPY_PC2011 = (TP100KPY / TP100KPY[.I == min(.I)] - 1)
                  ),
             by = c(BY[-1])]
      totals

      if (input$providers == 1) {
        totals[, PROVIDER_GRP := PROVIDER_GRP_LVLS[1]]
      } else {
        totals <- subset(totals, subset = PROVIDER_GRP %in% input$provider_grp)
      }

      if (input$anatomic == 1) {
        totals[, ANATOMIC_SEGMENT := ANATOMIC_SEGMENT_LVLS[1]]
      } else {
        totals <- subset(totals, subset = ANATOMIC_SEGMENT %in% input$anatomic_segment)
      }

      if (input$place_of_service == 1) {
        totals[, PLACE_OF_SERVICE_GRP := PLACE_OF_SERVICE_GRP_LVLS[1]]
      } else {
        totals <- subset(totals, subset = PLACE_OF_SERVICE_GRP %in% input$place_of_service_grp)
      }

      totals[, MS := Total / sum(Total), by = c(BY[BY != "PROVIDER_GRP"])]

      totals$PROVIDER_GRP %<>% factor(., levels = PROVIDER_GRP_LVLS)
      totals$ANATOMIC_SEGMENT %<>% factor(., levels = ANATOMIC_SEGMENT_LVLS)
      totals$PLACE_OF_SERVICE_GRP %<>% factor(., levels = PLACE_OF_SERVICE_GRP_LVLS)

      totals

    })# }}}

    output$plot1 <- renderPlotly({# {{{
      plotting_data <- reactiveData()
      pad_plot <- plot_ly(plotting_data, x = ~ YEAR) %>%
        add_trace(y = ~ Total,
                  color = ~ PROVIDER_GRP,
                  symbol = ~ ANATOMIC_SEGMENT,
                  linetype  = ~ PLACE_OF_SERVICE_GRP,
                  text = ~ MS,
                  type = "scatter",
                  mode = "lines+markers",
                  hovertemplate = "Total: %{y}<br>Market Share: %{text: .2%}"
                  ) %>%
        layout(showlegend = TRUE)

      pad_plot
    })# }}}

    output$plot2 <- renderPlotly({# {{{
      plotting_data <- reactiveData()
      pad_plot <- plot_ly(plotting_data, x = ~ YEAR)
      pad_plot %<>% add_trace(y = ~ Total_PC2011, name = "since 2011",      type = "scatter", mode = "lines+markers")
      pad_plot %<>% add_trace(y = ~ Total_PCPY,   name = "from prior year", type = "scatter", mode = "lines+markers", line = list(dash = "dot"))
      pad_plot %<>%  layout(yaxis = list(tickformat = ',.1%'), legend = list(orientation = "h"))
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

