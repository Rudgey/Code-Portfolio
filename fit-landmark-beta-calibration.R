
# Beta calibration as described by Kull (2017) in
# Beta calibration: a well-founded and easily implemented improvement on logistic calibration for binary classifiers
# http://proceedings.mlr.press/v54/kull17a/kull17a.pdf
# Extension to right-censored landmark data

# Data
# prob_event: estimated probability of an event.
# status: 0/1 presence of an event within a prediction window.
# ipcw_weight: inverse probability of censoring weights.

library(tidyverse)

# Function that scales using beta variables
predict_beta_probability <- function(p, c, a){
  # p - original probabiliy
  # c - incercept from beta regression
  # a - coefficient from beta regression
  
  # If p == 0 or p == 1, return p
  if (p == 0 | p == 1){
    
    return(p)
    
  } else {
    
    1/(1 + (1/(exp(c)*((p^a)/((1 - p)^a)))))
    
  }
  
}


# Landmark as a factor
data %<>%
  dplyr::mutate(landmark = forcats::as_factor(landmark))


# Filter 0 or 1 probabilities
# These will get mapped to themselves
data %<>%
  dplyr::filter(!prob_event == 0, !prob_event == 1)


# Transform prob_event
data %<>%
  dplyr::mutate(beta_variable = log(prob_event) - log(1 - prob_event))

# Fit Model
model <- glm(
  status ~ beta_variable:landmark + landmark,
  family = binomial(link = 'logit'),
  weights = ipcw_weight,
  data = data
)

# Test ####

# Extract parameters
intercept <- broom::tidy(model) %>%
  dplyr::filter(term == '(Intercept)') %>%
  dplyr::pull(estimate)

# Landmark specific intercept
beta_calibration_c <- broom::tidy(model) %>%
  dplyr::filter(stringr::str_starts(term, "landmark")) %>%
  dplyr::mutate(landmark = stringr::str_extract(term, "\\d+$")) %>%
  dplyr::select(landmark, estimate) %>%
  dplyr::rename(beta_c = estimate) %>%
  # Add intercept
  dplyr::mutate(beta_c = beta_c + intercept) %>%
  # Add landmark 1 which was absorbed into intercept
  dplyr::bind_rows(
    tibble(landmark = '1', beta_c = intercept)
  )

# Slope
beta_calibration_a <- broom::tidy(model) %>%
  dplyr::filter(!term == '(Intercept)' & !stringr::str_starts(term, "landmark")) %>%
  dplyr::mutate(landmark = stringr::str_extract(term, "\\d+$")) %>%
  dplyr::select(landmark, estimate) %>%
  dplyr::rename(beta_a = estimate)


# Add parameters
data %<>%
  dplyr::left_join(beta_calibration_c, by = 'landmark') %>%
  dplyr::left_join(beta_calibration_a, by = 'landmark')


# Predict
data %<>%
  dplyr::rowwise() %>%
  dplyr::mutate(prob_event_calibrated = predict_beta_probability(
    p = prob_event,
    c = beta_c,
    a = beta_a)
  ) %>%
  dplyr::ungroup()


# Test weak calibration 

# Before
data %>%
  dplyr::group_by(landmark) %>%
  dplyr::summarise(
    mean_prediction = mean(prob_event),
    class_proportion = sum((status == 1)*ipcw_weight)/(sum(ipcw_weight))
  ) %>%
  dplyr::mutate(ratio = mean_prediction/class_proportion)

# After
data %>%
  dplyr::group_by(landmark) %>%
  dplyr::summarise(
    mean_prediction = mean(prob_event_calibrated),
    class_proportion = sum((status == 1)*ipcw_weight)/sum(ipcw_weight)
  ) %>%
  dplyr::mutate(ratio = mean_prediction/class_proportion)


# Calibration plot
# Before
data %>%
  dplyr::group_by(landmark) %>%
  dplyr::mutate(calibration_bin = cut_number(prob_event, n = 10)) %>%
  dplyr::group_by(landmark, calibration_bin) %>%
  dplyr::summarise(
    predicted = mean(prob_event),
    observed = sum((status == 1)*ipcw_weight)/(sum(ipcw_weight))
  ) %>%
  ggplot(aes(x = observed, y = predicted, colour = landmark)) +
  geom_point() +
  geom_line() +
  geom_abline(intercept = 0, slope = 1, linetype = 'dotted') +
  xlim(0,1) +
  ylim(0,1)

# After
data %>%
  dplyr::group_by(landmark) %>%
  dplyr::mutate(calibration_bin = cut_number(prob_event_calibrated, n = 10)) %>%
  dplyr::group_by(landmark, calibration_bin) %>%
  dplyr::summarise(
    predicted = mean(prob_event_calibrated),
    observed = sum((status == 1)*ipcw_weight)/(sum(ipcw_weight))
  ) %>%
  ggplot(aes(x = observed, y = predicted, colour = landmark)) +
  geom_point() +
  geom_line() +
  geom_abline(intercept = 0, slope = 1, linetype = 'dotted') +
  xlim(0,1) +
  ylim(0,1)
