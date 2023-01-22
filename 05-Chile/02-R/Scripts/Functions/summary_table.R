summary_table <- function(data, vars) {
  
  data %>%  
    summarise(
      across({{ vars }},
             list(
               n    = ~ sum(!is.na(.x)),
               mean = ~ mean(.x, na.rm = TRUE)       ,
               sd   = ~ sd(.x, na.rm = TRUE)         ,
               min  = ~ min(.x, na.rm = TRUE)        ,
               max  = ~ max(.x, na.rm = TRUE)),
             .names = "{.col}-{.fn}")) %>% 
    pivot_longer(everything()) %>% 
    separate(name, sep = "-", into = c("var","stat"))  %>% 
    pivot_wider(names_from = "stat", values_from = "value") %>% 
    mutate_if(
      is.numeric,
      funs(
        format(., )
      )
    )
}