source("minos/transitions/utils.R")

get.sf12.files <- function(source, year1, year2){
  # get files for year 1 and year 2 respectively.
  file_name <- get_US_file_names(source, year1)[3]
  data <- get_US_data(file_name)
  file_name2 <- get_US_file_names(source, year2)[3]
  data2 <- get_US_data(file_name2)
  data_files <- list("data1" = data, "data2" = data2)
  return(data_files)
}

get.sf12.file.name <- function(destination, year1, year2){
  # Rda file names for clm outputs. annoying string concatenation.
  file_name <- paste0(destination, "sf12_ols_")
  file_name <- paste0(file_name, str(year1))
  file_name <- paste0(file_name, "_")
  file_name <- paste0(file_name, str(year2))
  file_name <- paste0(file_name, ".rds")
  return(file_name)
}

sf12.main <- function(years){
  for (year in years){
    data_source<- "data/final_US/"
    data_files <- get.sf12.files(data_source, year, year+1)
    data <- data_files$data1
    data2 <- data_files$data2
    
    # only look at individuals with data in both waves.
    common <- intersect(data$pidp, data2$pidp)
    data <- data[which(data$pidp %in% common), ]
    data2 <- data2[which(data2$pidp %in% common), ]
    data2 <- data2[, c("pidp", "SF_12")]
    colnames(data2) <- c("pidp", "y")
    data <- merge(data, data2,"pidp")
    data <- data[complete.cases(data),]
    formula <- "y ~ factor(sex) + 
                    factor(ethnicity) + 
                    age + 
                    factor(education_state) + 
                    factor(labour_state) + 
                    factor(job_sec) +
                    hh_income"
    sf12.lm <- lm(formula, 
                  data= data)
    sf12.file.name <- get.sf12.file.name("data/transitions/mwb/ols/", year, year+1)
    saveRDS(sf12.lm, file=sf12.file.name)
    print("Saved to:")
    print(sf12.file.name)
  }
}

years <- seq(2009,2018)
sf12.main(years)