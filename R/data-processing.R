library(readxl)
library(dplyr)
library(magrittr)

# Load Data ---------------------------------------------------------------

# IGP Facility Data
igp <- read_excel("data/raw/ind-app_specific-data_2019-12-04.xls", col_types = "text")

active <- igp %>%
  dplyr::filter(STATUS == "Active")

# IGP Level 1/2 Facility Data
elevated_data <- read_excel("data/raw/smarts_data_2019-12-04.xls", col_types = "text")

names(elevated_data) <- names(elevated_data) %>% make.names()


# Wrangle Data ------------------------------------------------------------

elevated <- elevated_data %>%
  dplyr::select(WDID, Pollutant, Demonstration, Level, Exceed.NAL, Instantaneous)

elevated <- elevated %>%
  dplyr::mutate(LevPoll = paste0(Level, ": ", Pollutant)) %>%
  dplyr::select(-Pollutant, -Level)

elevated_total <- elevated %>%
  dplyr::group_by(WDID) %>%
  dplyr::summarize_all(funs(trimws(paste(., collapse = '; '))))

combined_data <- dplyr::left_join(active, elevated_total, by = "WDID")

saveRDS(combined_data, file = "data/facility-data-2019-12-04.RDS")
