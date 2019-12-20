if(!require(cms.hcpcs)) {
  devtools::install_github("dewittpe/cms.hcpcs")
  library(cms.hcpcs)
}

if (!require(cms.program.statistics)) {
  devtools::install_github("dewittpe/cms.program.statistics")
  library(cms.program.statistics)
}

if (!require(cms.psps)) {
  devtools::install_github("dewittpe/cms.psps")
  library(cms.psps)
  psps_download()
  psps_unzip()
}

library(magrittr)
library(data.table)
HCPCS_2019_Q4 <- as.data.table(HCPCS_2019_Q4)

# PAD_CODES as defined in the manuscript
PAD_CODES <-
  c("37220", "0238T", "37221", "37222", "37223", "37224", "37225", "37226",
    "37227", "37228", "37229", "37230", "37231", "37232", "37233", "37234",
    "37235")

# PAD_CODES <-
HCPCS_2019_Q4[HCPCS %in% PAD_CODES]

# PSPS data from 2011 and beyond
psps_2011 <- psps_import_2011()
psps_2011 %<>% .[HCPCS_CD %in% PAD_CODES]

psps_2012 <- psps_import_2012()
psps_2012 %<>% .[HCPCS_CD %in% PAD_CODES]

psps_2013 <- psps_import_2013()
psps_2013 %<>% .[HCPCS_CD %in% PAD_CODES]

psps_2014 <- psps_import_2014()
psps_2014 %<>% .[HCPCS_CD %in% PAD_CODES]

psps_2015 <- psps_import_2015()
psps_2015 %<>% .[HCPCS_CD %in% PAD_CODES]

psps_2016 <- psps_import_2016()
psps_2016 %<>% .[HCPCS_CD %in% PAD_CODES]

psps_2017 <- psps_import_2017()
psps_2017 %<>% .[HCPCS_CD %in% PAD_CODES]

psps_2018 <- psps_import_2018()
psps_2018 %<>% .[HCPCS_CD %in% PAD_CODES]

PSPS_DATA <-
  rbindlist(list(psps_2011, psps_2012, psps_2013, psps_2014,
                 psps_2015, psps_2016, psps_2017, psps_2018))

# Enrollment
ENROLLMENT <- as.data.table(cms.program.statistics::MDCR_ENROLL_AB_01[, c("Year", "Total Enrollment")])
setnames(ENROLLMENT, old = "Year", new = "YEAR")
setnames(ENROLLMENT, old = "Total Enrollment", new = "ENROLLMENT")

# Place of Service
PLACE_OF_SERVICE <- as.data.table(cms.program.statistics::PLACE_OF_SERVICE)
PLACE_OF_SERVICE[, PLACE_OF_SERVICE_GRP := "Other"]
PLACE_OF_SERVICE[grepl("Ambulatory Surgical Center",       `Place of Service Name`), PLACE_OF_SERVICE_GRP := "Ambulatory Surgical Center"]
PLACE_OF_SERVICE[grepl("Independent Clinic",               `Place of Service Name`), PLACE_OF_SERVICE_GRP := "Ambulatory Clinic"]
PLACE_OF_SERVICE[grepl("^(Emergency Room|Urgent Care).+$", `Place of Service Name`), PLACE_OF_SERVICE_GRP := "Emergency Room"]
PLACE_OF_SERVICE[grepl("^Inpatient.+$",                    `Place of Service Name`), PLACE_OF_SERVICE_GRP := "Inpatient Hospital"]
PLACE_OF_SERVICE[grepl("^Office$",                         `Place of Service Name`), PLACE_OF_SERVICE_GRP := "Office"]
PLACE_OF_SERVICE[grepl(".+Outpatient Hospital$",           `Place of Service Name`), PLACE_OF_SERVICE_GRP := "Outpatient Hospital"]

# Provider Taxonomy
PROVIDER_TAXONOMY <- as.data.table(cms.program.statistics::PROVIDER_TAXONOMY)
PROVIDER_TAXONOMY[, PROVIDER_GRP := "Other"]
PROVIDER_TAXONOMY[`MEDICARE SPECIALTY CODE` %in% c("30", "36", "94"),                   PROVIDER_GRP := "Radiology"]
PROVIDER_TAXONOMY[`MEDICARE SPECIALTY CODE` %in% c("06", "11", "21", "76", "C3", "C7"), PROVIDER_GRP := "Cardiology"]
PROVIDER_TAXONOMY[`MEDICARE SPECIALTY CODE` %in% c("02", "28", "33", "77", "78"),       PROVIDER_GRP := "Surgery"]
PROVIDER_TAXONOMY <- unique(PROVIDER_TAXONOMY[, c("MEDICARE SPECIALTY CODE", "PROVIDER_GRP")])

# PAD Data
PAD_DATA <-
  PSPS_DATA %>%
  merge(., ENROLLMENT, by = "YEAR", all.x = TRUE, all.y = FALSE) %>%
  merge(., PLACE_OF_SERVICE, by.x = "PLACE_OF_SERVICE_CD", by.y = "Place of Service Code", all.x = TRUE, all.y = FALSE) %>%
  merge(., PROVIDER_TAXONOMY, by.x = "PROVIDER_SPEC_CD", by.y = "MEDICARE SPECIALTY CODE", all.x = TRUE, all.y = FALSE)
dim(PAD_DATA)

PAD_DATA[, HCPCS_INITIAL_MODIFIER_CD := NULL]
PAD_DATA[, CARRIER_NUM               := NULL]
PAD_DATA[, PRICING_LOCALITY_CD       := NULL]
PAD_DATA[, TYPE_OF_SERVICE_CD        := NULL]
PAD_DATA[, HCPCS_SECOND_MODIFIER_CD  := NULL]
PAD_DATA[, PSPS_SUBMITTED_CHARGE_AMT := NULL]
PAD_DATA[, PSPS_ALLOWED_CHARGE_AMT   := NULL]
PAD_DATA[, PSPS_DENIED_SERVICES_CNT  := NULL]
PAD_DATA[, PSPS_DENIED_CHARGE_AMT    := NULL]
PAD_DATA[, PSPS_ASSIGNED_SERVICES_CNT:= NULL]
PAD_DATA[, PSPS_NCH_PAYMENT_AMT      := NULL]
PAD_DATA[, PSPS_HCPCS_ASC_IND_CD     := NULL]
PAD_DATA[, PSPS_ERROR_IND_CD         := NULL]
PAD_DATA[, HCPCS_BETOS_CD            := NULL]
PAD_DATA[, `Place of Service Name`   := NULL]

# Anatomic Segment
PAD_DATA[HCPCS_CD == "37220" , `:=`(ANATOMIC_SEGMENT = "Iliac"             , PROCEDURE = "PTA"                         , PLACEMENT = "initial")]
PAD_DATA[HCPCS_CD == "0238T" , `:=`(ANATOMIC_SEGMENT = "Iliac"             , PROCEDURE = "atherectomy"                 , PLACEMENT = "each vessel")]
PAD_DATA[HCPCS_CD == "37221" , `:=`(ANATOMIC_SEGMENT = "Iliac"             , PROCEDURE = "stent"                       , PLACEMENT = "initial")]
PAD_DATA[HCPCS_CD == "37222" , `:=`(ANATOMIC_SEGMENT = "Iliac"             , PROCEDURE = "PTA"                         , PLACEMENT = "each additional")]
PAD_DATA[HCPCS_CD == "37223" , `:=`(ANATOMIC_SEGMENT = "Iliac"             , PROCEDURE = "stent"                       , PLACEMENT = "each additional")]
PAD_DATA[HCPCS_CD == "37224" , `:=`(ANATOMIC_SEGMENT = "Femoral/Popliteal" , PROCEDURE = "PTA"                         , PLACEMENT = "")] 
PAD_DATA[HCPCS_CD == "37225" , `:=`(ANATOMIC_SEGMENT = "Femoral/Popliteal" , PROCEDURE = "atherectomy +/- PTA"         , PLACEMENT = "")] 
PAD_DATA[HCPCS_CD == "37226" , `:=`(ANATOMIC_SEGMENT = "Femoral/Popliteal" , PROCEDURE = "stent"                       , PLACEMENT = "")] 
PAD_DATA[HCPCS_CD == "37227" , `:=`(ANATOMIC_SEGMENT = "Femoral/Popliteal" , PROCEDURE = "atherectomy w/stent +/- PTA" , PLACEMENT = "")] 
PAD_DATA[HCPCS_CD == "37228" , `:=`(ANATOMIC_SEGMENT = "Tibial/Peroneal"   , PROCEDURE = "PTA"                         , PLACEMENT = "initial")]
PAD_DATA[HCPCS_CD == "37229" , `:=`(ANATOMIC_SEGMENT = "Tibial/Peroneal"   , PROCEDURE = "atherectomy +/- PTA"         , PLACEMENT = "initial")]
PAD_DATA[HCPCS_CD == "37230" , `:=`(ANATOMIC_SEGMENT = "Tibial/Peroneal"   , PROCEDURE = "stent"                       , PLACEMENT = "initial")]
PAD_DATA[HCPCS_CD == "37231" , `:=`(ANATOMIC_SEGMENT = "Tibial/Peroneal"   , PROCEDURE = "atherectomy w/stent +/- PTA" , PLACEMENT = "initial")]
PAD_DATA[HCPCS_CD == "37232" , `:=`(ANATOMIC_SEGMENT = "Tibial/Peroneal"   , PROCEDURE = "PTA"                         , PLACEMENT = "each additional")]
PAD_DATA[HCPCS_CD == "37233" , `:=`(ANATOMIC_SEGMENT = "Tibial/Peroneal"   , PROCEDURE = "atherectomy +/- PTA"         , PLACEMENT = "each additional")]
PAD_DATA[HCPCS_CD == "37234" , `:=`(ANATOMIC_SEGMENT = "Tibial/Peroneal"   , PROCEDURE = "stent"                       , PLACEMENT = "each additional")]
PAD_DATA[HCPCS_CD == "37235" , `:=`(ANATOMIC_SEGMENT = "Tibial/Peroneal"   , PROCEDURE = "atherectomy w/stent +/- PTA" , PLACEMENT = "each additional")]

save(PAD_DATA, file = '../data/PAD_DATA.rda')

# /* ------------------------------------------------------------------------ */
#                                 End of File
# /* ------------------------------------------------------------------------ */

