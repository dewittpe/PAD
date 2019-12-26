#' # Trends in Endovascular Peripheral Artery Disease Interventions by Provider Specialty and Clinical Setting in the Medicare Population
#'
#' The data summaries provided by this tool are a supplement to the manuscript
#' "*Trends in Clinical Setting and Provider Specialty for Endovascular Peripheral
#' Artery Disease Interventions for the Medicare population between 2011 and 2017*"
#' (in press, 2019) by Kristofer Schramm, Peter E. DeWitt, Stephanie Dybul, Paul
#' Rochon, P Patel, R Hieb, K Rodgers, R Ryu, M Wolhauer, Premal S Trivedi.  That
#' data in this application includes 2018 and will be extended as Medicare data
#' sets are updates and released publically.
#'
#' The code and data sets required to build this application can be found on
#' [Peter DeWitt's github](https://github.com/dewittpe/PAD) page.
#'
#'
#' ## Purpose:
#' Provide graphical descriptions of the trends in peripheral endovascular
#' interventions for treating peripheral artery disease (PAD) by physician
#' specialty, anatomic segment, and clinical location of services.
#'
#' ## Methods:
#' [Physican Supplier Procedure Summary](https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Physician-Supplier-Procedure-Summary/index)
#' (PSPS) files where queried for peripheral vascular interventions via Current
#' Procedural Terminology (CPT) codes.  The reported totals are submitted services
#' for all Medicare part B enrollees.  Services per 100,000 person years (100KPY)
#' are reported to account for the increasing Medicare enrollment form year to
#' year.  The "market share" for a provider group, the percentage of the total
#' services submitted attributed to a provider group, illustrates the relative
#' change from year to year in who is providing the services.
#'
#' R packages for working with the PSPS and general program statistics, the
#' foundation for this application, are available here:
#'
#' * [cms.psps](https://github.com/dewittpe/cms.psps)
#' * [cms.program.statistics](https://github.com/dewittpe/cms.program.statistics)
#' * [cms.hcpcs](https://github.com/dewittpe/cms.hcpcs)
#'
#' ## Notes
#'
#+ label = "setup", include = FALSE
library(magrittr)
library(data.table)
load("data/PAD_DATA.rda")
codes <- unique(PAD_DATA[, c("HCPCS_CD", "ANATOMIC_SEGMENT", "PROCEDURE", "PLACEMENT")])

#'
#' Current Procedural Terminology (CPT) codes for peripheral vascular
#' interventions.
#' echo = FALSE, results = "asis"
knitr::kable(codes[order(ANATOMIC_SEGMENT, HCPCS_CD)])
#'
#' # Using This Application
#'
#' Click on the
