import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import random


def variable_importance_rf(model, data, variable, nrep = 5):
  
  # Set a seed
  random.seed(42)
  
  # Data - test data prior to one hot encoding
  # Variable - variable we are permuting
  # nrep - how many times to permute
  
  # Split in X, y
  X = data.drop('psa', axis = 1)
  y = data['psa']
  
  # Original data
  X_original = X.copy()
  
  # One hot encoding
  X_original = pd.get_dummies(X_original,
    columns = [
      'age',
      'pso_duration',
      'bmi',
      'crp',
      'pv',
      'alcohol_status',
      'smoking_status'
      ])
  
  # Original probability
  probability_original = model.predict_proba(X_original)[:, 1]
  
  # Data predict
  data_predict = data.copy()[['psa']]

  # Numeric PsA
  data_predict = data_predict.rename(columns={'psa':'psa_numeric'})

  # Categorical PsA
  data_predict['psa_class'] = data_predict['psa_numeric']
  data_predict['psa_class'] = data_predict['psa_class'].replace(0, 'N')
  data_predict['psa_class'] = data_predict['psa_class'].replace(1, 'Y')
  
  # Attach Original probability
  data_predict['prob_event_original'] = probability_original
  
  # Add which variable we are permuting
  data_predict['variable'] = variable
  
  # Repeating nrep times
  for i in np.arange(1, nrep + 1, 1):
    
    # Permute column
    X_permuted = X.copy()
      
    X_permuted[variable] = np.random.permutation(X_permuted[variable])

    # One hot encoding
    X_permuted = pd.get_dummies(X_permuted,
      columns = [
        'age',
        'pso_duration',
        'bmi',
        'crp',
        'pv',
        'alcohol_status',
        'smoking_status'
        ])
    
    # Predict using model
    probability_permuted = model.predict_proba(X_permuted)[:, 1]
    
    # Store in data_predict
    data_predict[f"prob_event_permutation_{i}"] = probability_permuted
    
    
  print(f"Variable: {variable} completed.")
  
  return data_predict


