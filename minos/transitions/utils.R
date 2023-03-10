# File for common functions across multiple transition techniques.
# Useful for setting all R scripts to the right directory.
# Change as necessary

str<- toString
concat<- function(x, y){return(paste0(x, y))}
invlogit <- function(x){
  # inverse of standard logistic link function
  # note defaults to 1 if x is large enough.
  # R max float size is 1.797693e+308. so if x > log(1.797693e+308) = 709.7827 
  # defaults to 1.
  # Practically any invlogit(x) for x > 100 is close enough to 1 (within 10^-16) 
  # to be indistinguishable. 
  if (is.na(x)){
  out = NA
  }
  else if (x > 100){
    out = 1
  }
  else{
    out = 1/(1 + exp(-x))
  }
  return (out)
}

#replace_missing <- function(data){
#  data <- na_if(data, "-1")
#  data <- na_if(data, "-2")
#  data <- na_if(data, "-7")
#  data <- na_if(data, "-8")
#  data <- na_if(data, "-9")
#  data <- na_if(data, -1)
#  data <- na_if(data, -7)
#  data <- na_if(data, -2)
#  data <- na_if(data, -8)
#  data <- na_if(data, -9)
#  data <- na_if(data, -1.)
#  data <- na_if(data, -2.)
#  data <- na_if(data, -7.)
#  data <- na_if(data, -8.)
#  data <- na_if(data, -9.)
#  return(data)
#}

missing.str <- c("-1", "-2", "-7", "-8", "-9", "-10")
missing.int <- c(-1, -2, -7, -8, -9, -10)
missing.float <- c(-1., -2., -7., -8., -9., -10.)
# replacement of missing values with NA that R can read. 
# May be a better way of doing this...
replace.missing <- function(data){
  data <- lapply(data, function(x) replace(x, x %in% missing.str, NA))
  data <- lapply(data, function(x) replace(x, x %in% missing.int, NA))
  data <- lapply(data, function(x) replace(x, x %in% missing.float, NA))
  return(as.data.frame(data))
}

# standard python style two tone colours to use. 
# t_ variants are lower 25% opacity.
t_blue<- rgb(56/256,180/256,251/256,0.25)
blue<- rgb(56/256,180/256,251/256,1.0)
t_orange <- rgb(255/256, 91/256, 0, 0.25)
orange <-rgb(255/256, 91/256, 0, 1.0)

create.if.not.exists <- function(path) {
    if(!file.exists(path)) {
        dir.create(path = path)
    }
}

get_US_file_names <- function(source, years, extension){
  file_names = c()
  for(year in years){
    # loop over years and load in files.
    file_name <- concat(source, str(year))
    file_name <- paste0(concat(file_name, extension))
    file_names <- append(file_names, file_name)
  }
  return(file_names)
}

get_US_data <- function(file_names){
  first_time <- T
  for(file in file_names){
    new_data <- read.csv(file)
    if (first_time==T){
      first_time <- F
      data <- new_data
    }
    else{
      data<- rbind(data, new_data)
    }
  }
  return(data)
}

format_US_housing_data <- function(data){
  # get desired columns.
  columns <- c("pidp", 
               "hidp", 
               "education_state", 
               "sex", 
               "age",
               "SF.12",
               "ethnicity",
               "depression_change",
               "labour_state",
               "job_sec",
               "fridge_freezer", 
               "washing_machine", 
               "tumble_dryer", 
               "dishwasher", 
               "microwave", 
               "heating",
               "hh_netinc")
  data<- data[, columns]
  colnames(data) <- c("pidp", 
                      "hidp", 
                      "education_state", 
                      "sex", 
                      "age",
                      "SF-12",
                      "ethnicity",
                      "depression_change",
                      "labour_state",
                      "job_sec",
                      "fridge_freezer", 
                      "washing_machine", 
                      "tumble_dryer", 
                      "dishwasher", 
                      "microwave", 
                      "heating",
                      "hh_netinc")
  # Remove anyone with fewer than 2 entries
  complete_pidps<- strtoi(rownames(data.frame(which(table(data$pidp)>=2))))
  data<- data[which(data$pidp%in%complete_pidps),]
  # household variables to be composited together. heating is not for now. 
  #??anyone missing one of the 5 variables is missing all of them. suggesting 
  # data collection error due to proxy or attrition. 
  #??sum(complete.cases(data[,c("fridge_freezer",
  #                        "washing_machine",
  #                        "tumble_dryer",
  #                        "dishwasher",
  #                        "microwave")]))- 
  # sum(complete.cases(data[,c("fridge_freezer")]))
  # 1440/ cases that are missing just heating.
  # 
  # [1] 0 suggesting anyone missing one is missing all of them. 
  household_vars = c("fridge_freezer",
                     "washing_machine",
                     "tumble_dryer",
                     "dishwasher",
                     "microwave",
                     "heating")
  # replace missing value codes with NAs so R can read them. 
  for(co in columns){
    i <- which(data[,co]%in%missing)
    data[,co] <- replace(data[,co], i, NA)
  }
  data$five_household <- rowSums(data[, c("fridge_freezer",
                                  "washing_machine",
                                  "tumble_dryer",
                                  "dishwasher",
                                  "microwave")])
  return(data)
}


format_employment_data <- function(source, years){
  
  first_time = T # if its the first year in the loop create the data frame.
  for(year in years){
    # loop over years and load in files.
    file_name <- concat(source, str(year))
    file_name <- paste0(concat(file_name, "_US_cohort.csv"))
    new_data <- read.csv(file_name)
    if (first_time==T){
      first_time <- F
      data <- new_data
    }
    else{
      data<- rbind(data, new_data)
    }
  }
  columns <- c("pidp", "sex", "age", "time", "education_state", "depression_state", "labour_state", "job_sec", "ethnicity")
  final_labour_states<- c("Retired",
                          "Family Care",
                          "Unemployed",
                          "Student",
                          "Sick/Disabled",
                          "Employed",
                          "Self-employed")
  # who is in the desired final labour states
  who_not_omitted<- which(data$labour_state %in% final_labour_states) 
  # remove irrelvalant columns and those in undesired labour states
  data<- data[who_not_omitted, columns]
  
  #Simplify depression state.
  who_decreasing = which(data$depression_state <= 2)
  who_increasing = which(data$depression_state > 2)
  
  data[who_decreasing,]$depression_state = 0
  data[who_increasing,]$depression_state = 1
  
  # Remove anyone with fewer than 3 entries
  complete_pidps<- strtoi(rownames(data.frame(which(table(data$pidp)>=3))))
  data<- data[which(data$pidp%in%complete_pidps),]
  return(data)  
}


get.two.files <- function(source, year1, year2){
  # Get files for year1 and year2. 
  # When estimating transitions to next year need predictor from year 1
  #??and response variable from year2.
  file_name <- get_US_file_names(source, year1, "_US_cohort.csv")
  data <- get_US_data(file_name)
  file_name2 <- get_US_file_names(source, year2, "_US_cohort.csv")
  data2 <- get_US_data(file_name2)
  data_files <- list("data1" = data, "data2" = data2)
  return(data_files)
}