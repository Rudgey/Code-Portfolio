library(tidyverse)
library(magrittr)
library(survival)



# Function to create landmark data given a landmark time and horizon

create_landmark_data <- function(data, landmark_time, window_size) {

  # Add landmark to the data
  data_landmark <- data %>%
    dplyr::mutate(landmark = landmark_time)
  
  
  # Last observation carried forward to the landmark
  data_landmark %<>%
    dplyr::filter(year <= landmark) %>%
    dplyr::arrange(patid, desc(year)) %>%
    dplyr::group_by(patid) %>%
    dplyr::slice_head(n = 1) %>%
    # No longer need year
    dplyr::select(-year)
  
  # Remove patients censored prior to the landmark
  data_landmark %<>%
    dplyr::filter(!study_end_year <= landmark)
  
  # Does a person experience the event in the prediction window
  # Status
  data_landmark %<>%
    dplyr::mutate(status_lm = dplyr::case_when((status == 1) &
                                                 (study_end_year <= landmark + window_size) ~ 1,
                                               TRUE ~ 0
    )) %>%
    dplyr::select(-status) %>%
    dplyr::rename(status = status_lm)
  
  # Observed time - truncate at end of window
  data_landmark %<>%
    dplyr::mutate(study_end_year_lm = pmin(study_end_year, landmark + window_size)) %>%
    dplyr::select(-study_end_year) %>%
    # Rename as time to match coxph
    dplyr::rename(time = study_end_year_lm)
  
  # Zero time at the landmark time
  data_landmark %<>%
    dplyr::mutate(time = time - landmark)
  
  # Relocate columns
  data_landmark %<>%
    dplyr::relocate(status, .after = 'patid') %>%
    dplyr::relocate(time, .after = 'status') %>%
    dplyr::relocate(landmark, .after = 'patid')
  
  
  # Return
  return(data_landmark)
  
  
}
