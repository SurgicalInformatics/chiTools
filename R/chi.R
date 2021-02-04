#' Extract date of birth from Community Health Index (CHI) number
#'
#' The Community Health Index (CHI) is a population register used in Scotland
#' for health care purposes. The CHI number uniquely identifies a person on the
#' index. Note `cutoff_2000`. As CHI has only a two digit year, you need to
#' specify whether year is 1900s or 2000s. The cut-off determines the year
#' before that number is considered 2000s i.e. at cutoff_2000 = 20, "18" is
#' considered 2018, rather than 1918.

#' @param .data Character. A vector of CHIs as characters/strings.
#' @param cutoff_2000 Integer. Two-digit year before which is considered 2000s.
#'
#' @return Vector of `Dates`.
#' @export
#'
#' @examples
#' library(dplyr)
#' # These CHIs are not real.
#  # The first is invalid, two and three are valid.
#' chi = c("1009701234", "1811431232", "1304496368")
#'
#' chi_dob(chi)
#'
#' tibble(chi = chi) %>%
#'   mutate(
#'     dob = chi_dob(chi)
#'   )
chi_dob = function(.data, cutoff_2000 = 20){
  .data %>%
    clean_chi() %>%
    stringr::str_extract(".{6}") %>%
    lubridate::parse_date_time2("dmy", cutoff_2000 = cutoff_2000) %>%
    lubridate::as_date() # Make Date object, rather than POSIXct
}



#' Extract gender from Community Health Index (CHI) number
#'
#' @param .data Character. A vector of CHIs as characters/strings.
#'
#' @return Factor with two levels "Female", "Male"
#' @export
#'
#' @examples
#' library(dplyr)
#' # These CHIs are not real.
#  # The first is invalid, two and three are valid.
#' chi = c("1009701234", "1811431232", "1304496368")
#'
#' chi_gender(chi)
#' # From tibble
#' tibble(chi = chi) %>%
#'   mutate(
#'     gender = chi_gender(chi)
#'   )
chi_gender = function(.data){
  .data %>%
    clean_chi() %>%
    stringr::str_sub(9, 9) %>%
    as.numeric() %>%
    {ifelse(. %% 2 == 0, "Female", "Male")}
}


#' Determine an age from Community Health Index (CHI) number
#'
#' @param .data Character. A vector of CHIs as characters/strings.
#' @param ref_date Dates. Single date or vector with same length as \code{.data}.
#' @param cutoff_2000 Integer. Two-digit year before which is considered 2000s.
#'
#' @return A vector of ages.
#' @export
#'
#' @examples
#' library(dplyr)
#' # These CHIs are not real.
#  # The first is invalid, two and three are valid.
#' chi = c("1009701234", "1811431232", "1304496368")
#'
#' # Age today
#' chi_age(chi, Sys.time())
#'
#' # Age on a single date
#' library(lubridate)
#' chi_age(chi, dmy("11/09/2018"))
#'
#' # Age on a vector of dates
#' dates = dmy("11/09/2018",
#'             "09/05/2015",
#'             "10/03/2014")
#' chi_age(chi, dates)
#' # From tibble
#' tibble(chi = chi) %>%
#'   mutate(
#'     age = chi_age(chi, Sys.time())
#'   )
chi_age = function(.data, ref_date, cutoff_2000 = 20){
  dob = .data %>%
    clean_chi() %>%
    chi_dob(cutoff_2000 = cutoff_2000)
  lubridate::interval(dob, ref_date) %>%
    as.numeric("years") %>%
    floor()
}


#' Test for valid Community Health Index (CHI) number
#'
#' Modulus 11 test on final digit to ensure CHI numnber is valid.
#'
#' @param .data Character. A vector of CHIs as characters/strings.
#'
#' @return A logical vector with \code{FALSE} indicating a non-valid CHI.
#' @export
#'
#' @examples
#' library(dplyr)
#' # These CHIs are not real.
#  # The first is invalid, two and three are valid.
#' chi = c("1009701234", "1811431232", "1304496368")
#'
#' chi_valid(chi)
#' # From tibble
#' tibble(chi = chi) %>%
#'   mutate(
#'     chi_valid = chi_valid(chi)
#'   )
chi_valid = function(.data){
  .data %>%
    clean_chi() %>%
    stringr::str_split("", simplify = TRUE) %>%
    .[, -10, drop=FALSE] %>%   # Working with matrices hence brackets
    apply(1, as.numeric) %>%   # Convert from string (and transpose)
    {seq(10, 2) %*% .} %>%     # Multiply and sum step
    {. %% 11} %>%              # Modulus 11
    {11 - .} %>%               # Substract from 11
    dplyr::near(               # Compare result with 10th digit.
      {stringr::str_sub(.data, 10) %>% as.numeric()}
    ) %>%
    as.vector()
}



#' Clean CHI
#'
#' @param .data
#'
#' @keywords internal
#' @export
#' @examples
#' chi = c("1009701234", "1811431232", "1304496368",
#'   "10 10 19 1234", "   12 12 30 1 2 3 4    ")
#'   clean_chi(chi)
#'
#' # Extra digit will error
#' chi = "1009701234 3"
clean_chi = function(.data){
  if(!is.character(.data)) stop("CHIs must be character string. Try as.character().")

  # Trim all white space
  out = gsub(" ", "", .data)

  # Length check
  chi_length = stringr::str_length(out)
  if(!all(chi_length == 10, na.rm = TRUE)){
    chi_length_not10 = which(chi_length != 10)
    stop(paste("CHIs in position(s)", paste(chi_length_not10, collapse = ", "), "do not have 10 digits."))
  }
  return(out)
}

