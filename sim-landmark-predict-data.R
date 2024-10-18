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
# Simulate weights - probably not that realistic but good enough for this.
# If status == 0, you may be censored, or you may have made it event free to the 
# end of the prediction window.
# If censored, weight is 0, it not censored, weight will be fixed at, say, 3.
# If status == 1, you will have a non-zero weight between 0 and 3.

data %<>%
  dplyr::rowwise() %>%
  dplyr::mutate(ipcw_weight = dplyr::case_when(
    status == 0 ~ sample(
      x = c(0, 3),
      size = 1,
      prob = c(0.2, 0.8)
    ),
    status == 1 ~ runif(n = 1, min = 0, max = 3)
  ))
  
                  
                  
  



