library(tidyverse)
library(magrittr)

# Simulate landmark prediction data

n = 10000

data <- tibble(
  landmark = rep(1:5, each = n/5),
  prob_event = runif(n, min = 0, max = 1),
)

# Use probability to create a status but with some error

data %<>%
  # Throw in some error
  dplyr::mutate(
    prob_event_error = runif(n = n, min = -0.3, 0.3)
  ) %>%
  # Probability used to sample status
  dplyr::mutate(
    status_prob = prob_event + prob_event_error
  ) %>%
  # Cut off probs < 0 or > 1
  dplyr::mutate(
    status_prob = dplyr::case_when(
      status_prob > 1 ~ 0.99,
      status_prob < 0 ~ 0.01,
      TRUE ~ status_prob
    )
  ) %>%
  dplyr::rowwise() %>%
  # Sample status using probabilities
  dplyr::mutate(status = sample(
    x = c(0,1), 
    size = 1, 
    prob = c(1 - status_prob, status_prob))) %>%
  dplyr::select(-prob_event_error, -status_prob)


# IPCW weights
# Simulate weights - some should be zero if they do not experience an event
data %<>%
  dplyr::rowwise() %>%
  dplyr::mutate(ipcw_weight = dplyr::case_when(
    status == 0 ~ sample(
      x = c(0, runif(
        n = 1, min = 0, max = 3
      )),
      size = 1,
      prob = c(0.2, 0.8)
    ),
    status == 1 ~ runif(n = 1, min = 0, max = 3)
  ))
                  
# data %<>%
#   dplyr::mutate(ipcw_weight = 1)
                  
                  
                  


# Calculate calibration

# Weak calibration
data %>%
  dplyr::group_by(landmark) %>%
  dplyr::summarise(
    mean_prediction = mean(prob_event),
    class_proportion = sum((status == 1)*ipcw_weight)/(sum(ipcw_weight))
  ) %>%
  dplyr::mutate(ratio = mean_prediction/class_proportion)



