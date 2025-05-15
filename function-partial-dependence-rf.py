import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import random


def partial_dependence_rf(data, model, variable):
  
  # Data - test data before one hot encoding
    
  # Set seed
  random.seed(42)
  
  # Results
  results = pd.DataFrame()
  
  # Split in X, y
  X = data.drop('psa', axis = 1)
  y = data['psa']
  
  # Get levels of the variable
  variable_levels = X[variable].unique()
  variable_levels.sort()
  
  for level in variable_levels:
  
    # Replace all instances of the variable with the current level
    X_level = X.copy()
    
    X_level[variable] = level
    
    X_level[variable] = pd.Categorical(X_level[variable], categories = variable_levels)
    
    # One hot encoding
    X_level = pd.get_dummies(X_level,
      columns = [
        'age',
        'pso_duration',
        'bmi',
        'crp',
        'pv',
        'alcohol_status',
        'smoking_status'
        ])
        
        
    # Probability
    probability = model.predict_proba(X_level)[:, 1]
    
    # Results temp
    results_temp = pd.DataFrame({
          'variable' : variable,
          'level' : level,
          'prob_event' : probability}
    )
    
    results = pd.concat([results, results_temp], ignore_index = True)
    # For
    
  print(f"Variable: {variable} completed.")  
  
  # Return results
  return results
  
  # Function


  


