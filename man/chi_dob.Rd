% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chi.R
\name{chi_dob}
\alias{chi_dob}
\title{Extract date of birth from Community Health Index (CHI) number}
\usage{
chi_dob(.data, cutoff_2000 = 20)
}
\arguments{
\item{.data}{Character. A vector of CHIs as characters/strings.}

\item{cutoff_2000}{Integer. Two-digit year before which is considered 2000s.}
}
\value{
Vector of `Dates`.
}
\description{
The Community Health Index (CHI) is a population register used in Scotland
for health care purposes. The CHI number uniquely identifies a person on the
index. Note `cutoff_2000`. As CHI has only a two digit year, you need to
specify whether year is 1900s or 2000s. The cut-off determines the year
before that number is considered 2000s i.e. at cutoff_2000 = 20, "18" is
considered 2018, rather than 1918.
}
\examples{
library(dplyr)
# These CHIs are not real.
chi = c("1009701234", "1811431232", "1304496368")

chi_dob(chi)

tibble(chi = chi) \%>\%
  mutate(
    dob = chi_dob(chi)
  )
}
