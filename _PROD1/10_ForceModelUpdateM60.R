# ----------------------------------------------------------------------------------------
# R Script to build or update Deep Learning model for every Currency Pair
# ----------------------------------------------------------------------------------------
# (C) 2019 Vladimir Zhbanko
# https://www.udemy.com/course/self-learning-trading-robot/?referralCode=B95FC127BA32DA5298F4
#
# load libraries to use and custom functions
library(dplyr)
library(magrittr)
library(readr)
library(h2o)
library(lazytrade)

#path to user repo:
#!!!Change this path!!! 
path_user <- "C:/Users/fxtrams/Documents/000_TradingRepo/R_selflearning"

#### Read asset prices and indicators ==========================================
#absolute path with the data
path_data <- file.path(path_user, "_DATA")
# Vector of currency pairs

Pairs = c("EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY",
          "EURGBP", "EURJPY", "EURCHF", "EURNZD", "EURCAD", "EURAUD", "GBPAUD",
          "GBPCAD", "GBPCHF", "GBPJPY", "GBPNZD", "AUDCAD", "AUDCHF", "AUDJPY",
          "AUDNZD", "CADJPY", "CHFJPY", "NZDJPY", "NZDCAD", "NZDCHF", "CADCHF")  
#absolute path to store model objects (useful when scheduling tasks)
path_model <- file.path(path_user, "_MODELS")

#path to store logs data (e.g. duration of machine learning steps)
path_logs <- file.path(path_user, "_LOGS")

#record time when the script starts to run
time_start <- Sys.time()

h2o.init()

# Writing indicator and price change to the file
for (PAIR in Pairs) {
  ## PAIR <- "EURUSD"
 # performing Deep Learning Regression using the custom function
 aml_make_model(symbol = PAIR,
                timeframe = 60,
                path_model = path_model,
                path_data = path_data,
                force_update = TRUE)

}  
  
 # stop h2o engine
h2o.shutdown(prompt = F)

#record time when the script ended to run
time_end <- Sys.time()
#calculate total time difference in seconds
time_total <- difftime(time_end,time_start,units="sec")
#convert to numeric
as.double(time_total)

# extract number of rows in the datasets
x <- read_rds(file.path(path_data, "AI_RSIADXEURUSD60.rds"))
n_rows_x <- nrow(x)

#setup a log dataframe
logs <- data.frame(dtm = Sys.time(), time2run = time_total, nrows = n_rows_x)

#read existing log (if exists) and add there a new log data
if(!file.exists(file.path(path_logs, 'time_executeM60.rds'))){
  write_rds(logs, file.path(path_logs, 'time_executeM60.rds'))
} else {
  read_rds(file.path(path_logs, 'time_executeM60.rds')) %>% 
    bind_rows(logs) %>% 
    write_rds(file.path(path_logs, 'time_executeM60.rds'))
}

# outcome are the models files for each currency pair written to the folder /_MODELS

#set delay to insure h2o unit closes properly
Sys.sleep(5)