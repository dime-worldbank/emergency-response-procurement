# ------------------------------------------------------------------------------ #
#                           HONDURAS DATA WORK PUBLIC PROCUREMENT                #
#                                       World Bank                               #
#                                    April - 2022                                #
#                                                                                #
# ------------------------------------------------------------------------------ #
# --------------------------------------- #
#     Authors: Doino Ruggero (RA - DIME)  #                                       
# --------------------------------------- #

# ****************************************************************************** #
# This code is meant to download data from https://oncae.gob.hn/datosabiertos.   #
# One needs to run it using Rstudio to enter inputs that will tailor the output  #
# based on the user's needs.                                                     #
# ****************************************************************************** #
# April 04 2022

# ------------------------------------------------------------------------------- #
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# ******************************************************************************* #

# INTERACTIVE SESSION -----------------------------------------------------------------------

cat("\n \n \n This will be an interactive R session.\n You will be asked to answer some questions at the beggining and then it will autonomously run. \n \n \n")

{
  
  start_year        = readline("What is the time interval you are interested in? From (type one year from 2005 to 2021): ");
  end_year          = readline("; to (type one year from 2005 to 2021): ");
  folders           = readline("Do you need to create folders (Yes/No): ");
  download          = readline("Do you need to download data (Yes/No): ");
  cat("
  
  Let's do this!
      
      ")
  
}

# We ask the user if they need to download data. If they don't, we can skip this section. 

##### FOLDERS 

if (folders == "Yes") {
  
  years_raw   <- sprintf(paste0(projectFolder, "/Data/DCC/Raw/DCC_%d"), seq(2005, 2021)) 
  
  # We loop over "years" to create directories and folders for each year
  
  for (i in years_raw) {      # loop over each year from 2005 to 2021
    
    if (file.exists(i)) { # if the path with the new folder already exists, then nothing happens 
      
      cat("The folder already exists: ",i,"\n")
      
    } else {              # otherwise, we create a new path with the folder
      
      dir.create(paste0(projectFolder, "/Data"                 ))
      
      dir.create(paste0(projectFolder, "/Data/DCC"             ))
      
      dir.create(paste0(projectFolder, "/Data/DCC/Raw"         ))
      
      dir.create(paste0(projectFolder, "/Data/DCC/Final"         ))
      
      dir.create(paste0(projectFolder, "/Data/DCC/Intermediate"))
      
      dir.create(paste0(projectFolder, "/Data/DCC/Intermediate/1 - Panel data"))
      
      dir.create(i)
      
    }
    
  }
  
}

# DOWNLOAD DATA -----------------------------------------------------------------------

if (download == "Yes") {
  
  years <- sprintf("%d", seq(start_year,end_year)) 
  
  # We loop over "years" to create directories and folders for each year
  
  for (i in years) {      # loop over each year from 2005 to 2021
    
    url      <- paste0("https://datosabiertos.oncae.gob.hn/datosabiertos/HC1/HC1_datos_",i,".xlsx") # url for the extraction
    destfile <- file.path(projectFolder, paste0("Data/DCC/Raw/DCC_",i,"/DCC_",i,".xlsx"))           # directory to save the file downloaded
    
    download.file(url, destfile)
    
  }
  
}

# MERGE DATA -----------------------------------------------------------------------

years <- sprintf("%d", seq(start_year,end_year)) 

# Extract the name of each xlsx file for each year
names_list      <- file.path(projectFolder, paste0("Data/DCC/Raw/DCC_",years[1],"/DCC_",years[1],".xlsx"))

# This is the list of all sheets, 17 every year

list_names <- c(
  
  "releases"               ,
  "awa_documents"          ,
  "awa_items"              ,
  "awa_suppliers"          ,
  "awards"                 ,
  "con_documents"          ,
  "con_guarantees"         ,
  "con_suppliers"          ,
  "contracts"              ,
  "par_memberOf"           ,           
  "parties"                ,
  "pla_bud_budgetBreakdown",
  "sources"                , 
  "ten_documents"          ,
  "ten_items"              ,
  "ten_participationFees"  ,
  "ten_tenderers"
  
)

for (i in list_names) { # loop over name of the sheets
  
  if (i == "awa_items" & years[1] == 2005) {
    
    matrix           <- data.frame(matrix(NA, 1, 11))
    
    colnames(matrix) <- c(
      
      "ocid"                                       ,
      "id"                                         ,
      "awards/0/id"                                ,
      "awards/0/items/0/id"                        ,
      "awards/0/items/0/unit/name"                 ,
      "awards/0/items/0/unit/value/amount"         ,
      "awards/0/items/0/quantity"                  ,
      "awards/0/items/0/description"               ,
      "awards/0/items/0/classification/id"         ,
      "awards/0/items/0/classification/scheme"     ,
      "awards/0/items/0/classification/description"
      
    )
    
    write.xlsx2(
      
      matrix                   , 
      names_list               , 
      sheetName="awa_items"    , 
      row.names=FALSE          ,
      col.names=TRUE           , 
      append = TRUE
      
    )
    
  }
  
  if (i == "awa_suppliers" & years[1] == 2005) {
    
    matrix           <- data.frame(matrix(NA, 1, 5))
    
    colnames(matrix) <- c(
      
      "ocid"                                       ,
      "id"                                         ,
      "awards/0/id"                                ,
      "awards/0/suppliers/0/id"                    ,
      "awards/0/suppliers/0/name"      
      
    )
    
    write.xlsx2(
      
      matrix                   , 
      names_list               , 
      sheetName="awa_suppliers", 
      row.names=FALSE          ,
      col.names=TRUE           , 
      append = TRUE
      
    )
    
  }
  
  sheet        <- read_excel(names_list, i)
  
  if (i == "ten_items" & years[1] == 2005) {
    
    matrix           <- matrix(NA, nrow(sheet), 1)
    colnames(matrix) <- "tender/items/0/quantity"
    sheet            <- cbind(sheet, matrix)
    
  }
  
  for (j in years[2:length(years)]) { # loop over years
    
    # We extract the path for each year spreadsheet
    file      <- file.path(projectFolder, paste0("Data/DCC/Raw/DCC_",j,"/DCC_",j,".xlsx"))
    
    # Use the name to load the file 
    sheet_years           <- read_excel(file, i)
    
    sheet    <- rbind(sheet, sheet_years)
    
  }
  
  write_csv(sheet, file.path(projectFolder, paste0("Data/DCC/Intermediate/1 - Panel data/", "DCC_", i,".csv")))
  
}

# END -----------------------------------------------------------------------

cat("\n \n  \n Enjoy your data! \n \n \n")

