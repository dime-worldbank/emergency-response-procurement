#' Check and process the Chilean RUT (Rol Único Tributario)
#'
#' @param data A data.table containing the data
#' @param variable The column name containing the RUT strings to be checked
#' @param without_dots A logical value indicating whether the RUT strings contain dots or not
#'
#' @return A data.table with processed RUT strings
#' @export
#' 
#' @import data.table 
#' @import stringr 
#'
#' @examples
#' dt <- data.table(id = c("12.345.678-9", "98.765.432-1"))
#' rut_check(dt, id)
#' 

rut_check <- function(data, variable, without_dots = FALSE) {
  
  variable <- substitute(variable)  # Replacing enquo
  data <- as.data.table(data)  # Ensure the data is a data.table
  
  if(nchar(id_rut_firm) == 9) {
    
    
  }
  
  if(without_dots == TRUE) {
    data[, (variable) := str_remove_all(substr(get(variable), 0, nchar(get(variable)) - 1), pattern = "\\s")]
  } else {
    one_two_dgt <- "[0-9]{1,2}"
    three_dgt   <- "[0-9]{3}"
    pattern_rut <- paste0(one_two_dgt, "\\.", three_dgt, "\\.", three_dgt, "\\-")
    
    data[, (variable) := substr(get(variable), 0, nchar(get(variable)) - 1)]
    data[, (variable) := str_remove_all(get(variable), pattern = "\\s")]
    data[, (variable) := ifelse(str_detect(get(variable), pattern = pattern_rut), get(variable), NA)]
  }
  
  # Compute check digit
  data[, check_digit := gsub("[^0-9]", "", get(variable))]
  digits <- lapply(1:9, function(x) as.numeric(substr(data$check_digit, x, x)))
  setnames(data, "check_digit", "sum")
  
  for (i in 1:9) {
    set(data, j = paste0("digit_", i), value = digits[[i]])
  }
  
  weights <- c(2, 3, 4, 5, 6, 7, 2, 3, 4)
  data[, sum := rowSums(mapply(`*`, .SD, weights), na.rm = TRUE), .SDcols = paste0("digit_", 1:9)]
  data[, check_digit := 11 - (sum - (11 * (sum %/% 11)))]
  data[, check_digit := fifelse(check_digit == 11, 0, fifelse(check_digit == 10, "K", check_digit))]
  data[, (variable) := paste0(get(variable), check_digit)]
  
  data[, c("sum", paste0("digit_", 1:9)) := NULL]
  
  return(data)
}
