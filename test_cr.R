library(basilisk)
source("e:/YuNotebooks/01_Development/source/yulab-github/sclet/R/basilisk.R")
basiliskRun(sclet_cellrank_env, function() {
  reticulate::py_run_string("
import cellrank
from cellrank.estimators import GPCCA
print('predict_terminal_states:', 'predict_terminal_states' in dir(GPCCA))
print('compute_terminal_states:', 'compute_terminal_states' in dir(GPCCA))
print('compute_fate_probabilities:', 'compute_fate_probabilities' in dir(GPCCA))
print('compute_absorption_probabilities:', 'compute_absorption_probabilities' in dir(GPCCA))
print('terminal_states:', 'terminal_states' in dir(GPCCA))
print('fate_probabilities:', 'fate_probabilities' in dir(GPCCA))
print('absorption_probabilities:', 'absorption_probabilities' in dir(GPCCA))
")
})
