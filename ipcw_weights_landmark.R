library(tidyverse)
library(magrittr)
library(survival)
library(broom)

# Function that takes a dataframe containing time, status, landmark
# and attaches a column of ipcw weights
# w = prediction window width

add_ipcw_weights_landmark <- function(.data, w){
  
  # Add censoring status
  data_ipcw <- .data %>% 
    dplyr::mutate(censoring_status = 1 - status) %>%
    # Not censored if you reach the end of the window, or have an event.
    dplyr::mutate(censoring_status = dplyr::case_when(time == w ~ 0,
                                                      TRUE ~ censoring_status)) %>%
    dplyr::select(patid, landmark, time, censoring_status)
  
  # Kaplan meier
  # Stratified by landmark
  rkm <- survival::survfit(Surv(time, censoring_status) ~ strata(landmark),
                           type = 'kaplan-meier',
                           data = data_ipcw)
  
  ipcw <- rkm %>%
    tidy() 
  
  # Add landmark column
  # Extract the number at the end of the string
  ipcw %<>%
    dplyr::mutate(
      landmark = stringr::str_extract(strata, "\\d+$")
    ) 
  
  ipcw %<>%
    dplyr::select(time, landmark, estimate) %>%
    dplyr::rename(prob_censored = estimate)
  
  # Join censoring probabilities
  data_ipcw %<>%
    dplyr::left_join(ipcw, by = c('time', 'landmark'))
  
  
  # Weights = 1/prob
  data_ipcw %<>%
    dplyr::mutate(ipcw_weight = 1/prob_censored)
  
  # If censored, weight == 0
  data_ipcw %<>%
    dplyr::mutate(ipcw_weight = dplyr::case_when(censoring_status == 1 ~ 0,
                                            TRUE ~ ipcw_weight))
  
  ipcw_weights <- data_ipcw %>%
    dplyr::select(patid, landmark, ipcw_weight)
  
  # Add to predictions
  .data %<>%
    dplyr::left_join(ipcw_weights, by = c('patid', 'landmark'))
  
  
  return(.data)
  
}
