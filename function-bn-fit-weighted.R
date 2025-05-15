
# Function to fit the custom Bayesian Network (BN) 
# with the weightings on the target node


# Create a weighted Conditional probability table (CPT) for a specific node
fit.weighted.cpt <- function(node, parents, data, weights, target) {
  
  n = nrow(data)
  
  # Weights
  if (target %in% c(node, parents)){
    w = weights
  } else {
    w = rep(1, n)
  }
  
  x <- data %>% dplyr::select(tidyselect::all_of(node))
  
  y <- data %>% dplyr::select(tidyselect::all_of(parents))
  
  probs <- data.frame(x, y, w) %>%
    # Non-zero weights only
    dplyr::filter(w != 0) %>%
    dplyr::group_by(dplyr::across(tidyselect::all_of(c(node, parents))), .drop = FALSE) %>%
    # Smoothing to prevent probabilities of 0 or 1 when calculating counts
    dplyr::summarise(count = sum(w) + 1, .groups = 'drop') %>%
    dplyr::arrange(dplyr::across(tidyselect::all_of(rev(parents)))) %>%
    dplyr::group_by(dplyr::across(tidyselect::all_of(parents)), .drop = FALSE) %>%
    dplyr::mutate(prob = count/sum(count)) %>%
    dplyr::pull(prob)
  
  
  # Dimension of CPT
  xdim <- x %>% purrr::map_int(., .f = nlevels) %>% unname()
  
  ydim <- y %>% purrr::map_int(., .f = nlevels) %>% unname()
  
  dims <- c(xdim, ydim)
  
  # Dimnames
  dimnames = data.frame(x, y) %>% map(., .f = levels)
  
  cpt <- array(data = probs,
               dim = dims,
               dimnames = dimnames)
  
  return(cpt)
  
}

# For all nodes in a network structure
fit.weighted.network <- function(structure, data, weights, target) {
  
  nodes <- bnlearn::nodes(structure)
  weights <- weights
  
  fitted_cpts <- purrr::map(
    nodes,
    .f = function(x)
      fit.weighted.cpt(
        node = x,
        parents = bnlearn::parents(structure, node = x),
        data = data,
        weights = weights,
        target = target
      )
  ) %>% purrr::set_names(nodes)
  
  return(fitted_cpts)
  
}


# Fit BN

bn.fit.weighted = function(structure,
                           data,
                           weights,
                           target) {
  
  dist <- fit.weighted.network(structure = structure,
                               data = data,
                               weights = weights,
                               target = target)
  
  fit <- bnlearn::custom.fit(x = structure,
                             dist = dist)
  
  return(fit)
}
