# Rut checkin

rut_check <- function(data, variable, without_dots = FALSE, SII = FALSE) {
  
  variable <- enquo(variable)
  
  if (SII == FALSE) {
    
    if(without_dots == TRUE) {
      
      # We do a first cleaning
      data <- data %>% 
        mutate(
          var = substr(!!variable, 0, nchar(!!variable) - 1) # we remove the digit check
        ) %>% 
        mutate(
          var = str_remove_all(var, pattern = SPACE) # remove space
        ) 
      
    } else {
      
      # We code one and two digits 
      one_two_dgt <- or(DGT, DGT %R% DGT)
      three_dgt   <- DGT %R% DGT %R% DGT
      
      # This should be the pattern
      pattern_rut <- one_two_dgt %R%  "." %R% three_dgt %R% "." %R% three_dgt %R% "-"
      
      # We do a first cleaning
      data <- data %>% 
        mutate(
          var = substr(!!variable, 0, nchar(!!variable) - 1) # we remove the digit check
        ) %>% 
        mutate(
          var = str_remove_all(var, pattern = SPACE) # remove space
        ) %>% 
        mutate(
          var = ifelse(str_detect(var, pattern = pattern_rut), var, NA) # remove all variables that do not match the pattern
        ) 
      
    }
    
    # Now, we can recompute the check digit 
    data <- data %>% 
      mutate(
        check_digit = gsub('[^[:alnum:] ]','', var) # we keep only the numbers
      ) %>% 
      # we seperate each digit in columns 
      separate(check_digit, into = c('digit_1', 'digit_2', 'digit_3', 'digit_4', 'digit_5', 'digit_6', 'digit_7', 'digit_8'), sep = seq(1, 8, by = 1), remove = FALSE) %>% 
      # replace missing digit with a 0 
      mutate(digit_8 = ifelse(is.na(digit_8), 0, digit_8)) %>% 
      mutate(digit_8 = ifelse(digit_8 == "", 0, digit_8)) %>% 
      mutate(across(starts_with("digit"), ~ as.numeric(.x))) %>% 
      mutate(check_digit = as.numeric(check_digit)) %>% 
      # we compute the formula
      mutate(
        digit_1     = digit_8 * 2,
        digit_2     = digit_7 * 3,
        digit_3     = digit_6 * 4,
        digit_4     = digit_5 * 5,
        digit_5     = digit_4 * 6,
        digit_6     = digit_3 * 7,
        digit_7     = digit_2 * 2,
        digit_8     = digit_1 * 3,
        check_digit = (11 - (rowSums(select(., contains("digit"))) - (11*(trunc(rowSums(select(., contains("digit")))/11)))))
      ) %>% 
      mutate(
        check_digit = ifelse(check_digit == 11, 0, ifelse(
          check_digit == 10, "K", check_digit
        ))
      ) %>% 
      mutate(
        var = paste0(var, check_digit)
      ) %>% 
      select(
        -c("check_digit", starts_with("digit"))
      ) 
    
  } else if (SII == TRUE) {
    
    # Now, we can recompute the check digit 
    data <- data %>% 
      mutate(
        check_digit = as.character(rut) # we keep only the numbers
      ) %>% 
      # we seperate each digit in columns 
      separate(check_digit, into = c('digit_1', 'digit_2', 'digit_3', 'digit_4', 'digit_5', 'digit_6', 'digit_7', 'digit_8'), sep = seq(1, 8, by = 1), remove = FALSE) %>% 
      # replace missing digit with a 0 
      mutate(digit_8 = ifelse(is.na(digit_8), 0, digit_8)) %>% 
      mutate(digit_8 = ifelse(digit_8 == "", 0, digit_8)) %>% 
      mutate(across(starts_with("digit"), ~ as.numeric(.x))) %>% 
      mutate(check_digit = as.numeric(check_digit)) %>% 
      # we compute the formula
      mutate(
        digit_1     = digit_8 * 2,
        digit_2     = digit_7 * 3,
        digit_3     = digit_6 * 4,
        digit_4     = digit_5 * 5,
        digit_5     = digit_4 * 6,
        digit_6     = digit_3 * 7,
        digit_7     = digit_2 * 2,
        digit_8     = digit_1 * 3,
        check_digit = (11 - (rowSums(select(., contains("digit"))) - (11*(trunc(rowSums(select(., contains("digit")))/11)))))
      ) %>% 
      mutate(
        check_digit = ifelse(check_digit == 11, 0, ifelse(
          check_digit == 10, "K", check_digit
        ))
      ) %>% 
      mutate(
        rut = paste0(rut, check_digit)
      ) %>% 
      select(
        -c("check_digit", starts_with("digit"))
      ) 
    
  }
  
  return(data)
  
}