#' Bin continuous data into discrete intervals
#'
#' Similar to pandas.cut, divides data into bins.
#'
#' @param x Numeric vector to bin.
#' @param bins Number of bins or a vector of bin edges.
#' @param labels Labels for the bins (optional).
#' @param include.lowest Whether to include the lowest value in the first interval (default: TRUE).
#' @return A factor indicating bin membership for each element of x.
#' @examples
#' cut_bins(1:10, bins = 3)
#' @export
cut_bins <- function(x, bins, labels = NULL, include.lowest = TRUE) {
  if (length(bins) == 1) {
    return(
      cut(
        x,
        breaks = bins,
        labels = labels,
        include.lowest = include.lowest,
        right = TRUE
      )
    )
  } else {
    return(
      cut(
        x,
        breaks = bins,
        labels = labels,
        include.lowest = include.lowest,
        right = TRUE
      )
    )
  }
} 