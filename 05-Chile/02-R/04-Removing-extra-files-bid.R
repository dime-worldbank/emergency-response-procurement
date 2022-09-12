# Made by Leandro Veloso
# main: Deleting extra data

# Closing connection
closeAllConnections()

# 1: Removing compressed download files ----
for (k in seq_along(sequence_dates)) { 
  # Getting year month
  year  <- year(sequence_dates[k])
  month <- month(sequence_dates[k])
  
  # month leading zero
  month_str<- str_pad(month, 2, pad = "0")
  
  # displaying
  print(paste0("Excluding file -  ",month_str,"/",year ))
  
  # path to save
  path_raw <- paste0(dropbox_dir,"1 - import/1-compress/lic-",year, month_str,".zip")
  
  # Donwloading file and checking time
  file.remove(path_raw)
}

# 2: Removing csv raw files ----
for (k in seq_along(sequence_dates)) { 
  # Getting year month
  year  <- year(sequence_dates[k])
  month <- month(sequence_dates[k])
  
  # displaying
  print(paste0("Deleting ",year,"-",month,".csv")) 
  
  # CSV raw file
  csv_file <- paste0(dropbox_dir,"1 - import/2-unzipped/lic_",year,"-",month,".csv")
  
  # Extracting
  file.remove(csv_file)    
}

# 3: Removing temporary files ----
file_list<-list(dir(paste0(dropbox_dir,"2 - data_construct/1-data_temp")))[[1]]
for (file in  file_list) { 
  # Removing raw files
  full_file_path = paste0(dropbox_dir,"2 - data_construct/1-data_temp/",file)
  print(paste0("dropping: ",file))
  file.remove(full_file_path)
}
