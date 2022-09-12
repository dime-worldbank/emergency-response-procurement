# Made by Leandro Veloso
# main: download tender data from Chile procurement and unzip

# To retrieve an option
getOption('timeout')
options(timeout=3600)

# Downloading files- since it is normal to corrupted. It is checked.
for (laps in 1:10) {
  # Showing lap 
  print(paste("lap",laps))
  
  # source (example): https://transparenciachc.blob.core.windows.net/oc-da/2019-1.zip 
  url_down<- "https://transparenciachc.blob.core.windows.net/lic-da/"
  
  # Defyning year and month
  time_sum<-rep(NA,length(sequence_dates))
  for (k in seq_along(sequence_dates)) {
    # 1: Setting variable and path ----
    { 
      # Getting year month
      year  <- year(sequence_dates[k])
      month <- month(sequence_dates[k])
      # month leading zero
      month_str<- str_pad(month, 2, pad = "0")
      
      # Full url to download
      full_path<- paste0( url_down, year,"-",month,".zip")
      
      # path to save
      path_raw <- paste0(dropbox_dir,"1 - import/1-compress/tender-",year, month_str,".zip")
      
      # Output folder
      out_file <- paste0(dropbox_dir,"1 - import/2-unzipped")
      
      # File from zip
      file_name_path = paste0(out_file,"/", paste0("lic_",year,"-", month,".csv"))        
    }
    
    # 2: Downloading file and checking time ----
    if (!file.exists(path_raw) & !file.exists(file_name_path)) {
      # displaying
      print(paste0(" Downloading ",month_str,"/",year ))
      
      # Trying
      tryCatch({
        withTimeout(
          download.file(full_path, path_raw, quiet = TRUE, mode = "wb")     ,
          timeout = 3600)
      }, error=function(e){})
      
    } else {
      print(paste0(" File already exist ",month_str,"/",year ))
    }
    
    # 3: unzipping files ----
    {
      # Run if zip exist and csv from zip not
      if (file.exists(path_raw) & !file.exists(file_name_path)) {
        # Extracting
        file_corrupt <- tryCatch(
          unzip(zipfile = path_raw, exdir = out_file) 
          , error=function(e){})
        
        # Closing connection
        closeAllConnections()
        
        #file name
        file_name<- paste0("tender-",year, month_str,".zip")
        
        # Checking if it is corrupted
        if (is.null(file_corrupt)) {
          print(paste0("3:",file_name, ": corrupted"))
          file.remove(path_raw)
        } else {
          print(paste0("3:",file_name, ": unzipped"))
        }
      }
    }
  }
}

# 4: Checking files ----
print("Files to download again:") 
for (k in seq_along(sequence_dates)) { 
  # 1: Setting variable and path ----
  { 
    # Getting year month
    year  <- year(sequence_dates[k])
    month <- month(sequence_dates[k])
    # month leading zero
    month_str<- str_pad(month, 2, pad = "0")
  }
  
  # Output folder
  out_file <- paste0(dropbox_dir,"1 - import/2-unzipped")
  
  file_csv <- paste0("lic_",year,"-",month,".csv")
  file_csv_path <- paste0(out_file, "/", file_csv)
  file_zip_path <- paste0(dropbox_dir,"1 - import/1-compress/tender-",year, month_str,".zip")
  # Closing connection
  closeAllConnections()
  
  # Reading to check
  run_correct=TRUE
  tryCatch(
    {
      data_temp_check <- data.table::fread(file_csv_path, encoding = "Latin-1")
    },
    error=function(cond) {
      print("Error:",quote=FALSE)
      message(cond)
      # Choose a return value in case of error
      run_correct <<- FALSE
    },
    warning=function(cond) {
      print("Warning:",quote=FALSE)
      # Choose a return value in case of warning
      run_correct <<- FALSE
    }
  )  
  
  # Removing to save space
  if (exists("data_temp_check")==TRUE) rm(data_temp_check)
  
  # Printing
  if (run_correct==FALSE) {
    print(paste0(file_csv," corrupted"))
    file.remove(file_zip_path)
    file.remove(file_csv_path)
  } else {
    print(paste0(file_csv," ok"))
  }
}

# 5: list files to download
for (k in seq_along(sequence_dates)) {
  url_down<- "https://transparenciachc.blob.core.windows.net/lic-da/"
  
  # 1: Setting variable and path ----
  { 
    # Getting year month
    year  <- year(sequence_dates[k])
    month <- month(sequence_dates[k])
    # month leading zero
    month_str<- str_pad(month, 2, pad = "0")
    
    # Full url to download
    full_path<- paste0( url_down, year,"-",month,".zip")
    
    # Output folder
    out_file <- paste0(dropbox_dir,"1 - import/2-unzipped")
    
    # File from zip
    file_name_path = paste0(out_file,"/", paste0("lic_",year,"-", month,".csv"))        
  }
  
  # 2: Listing files to download ----
  if (!file.exists(file_name_path)) {
    # displaying
    print(full_path)
    
  }
}
