clean_string <- function(data, string) {
  
  data <- data %>% 
    
    mutate(
      new_string = str_to_upper({{string}})   ,
      new_string = gsub("\\s", "", new_string),
      new_string = gsub("[^[:alpha:][:alnum:]]", "", new_string)
    )
  
  return(data)
  
}