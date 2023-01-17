clean_string <- function(data, string) {
  
  data <- data %>% 
    
    mutate(
      string = str_to_upper(string)   ,
      string = gsub("\\s", "", string),
      string = gsub("[^[:alpha:][:alnum:]]", "", string)
    )
  
  return(data)
  
}