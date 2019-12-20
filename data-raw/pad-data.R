library(cms.hcpcs)
library(cms.psps)
library(data.table)
HCPCS_2019 <- as.data.table(HCPCS_2019)
HCPCS_2019_Q4 <- as.data.table(HCPCS_2019_Q4)

# PAD_CODES as defined in the manuscript
PAD_CODES <-
  c("37220", "0238T", "37221", "37222", "37223", "37224", "37225", "37226",
    "37227", "37228", "37229", "37230", "37231", "37232", "37233", "37234",
    "37235")

PAD_CODES <- HCPCS_2019_Q4[HCPCS %in% PAD_CODES]

# PSPS data from 2011 and beyond

check <- psps_md5sum()
if (!all(check$check)) {
  psps_download()
  psps_unzip()
}

psps_import_2011()
psps_import_2012()
psps_import_2013()
psps_import_2014()
psps_import_2015()
psps_import_2016()
psps_import_2017()
psps_import_2018()

