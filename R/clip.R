#' Clip (limit) values in a numeric vector
#'
#' Restrict values in a numeric vector to a specified range.
#'
#' @param x Numeric vector.
#' @param lower Lower bound (default: -Inf).
#' @param upper Upper bound (default: Inf).
#' @return Numeric vector with values limited to [lower, upper].
#' @examples
#' clip(c(-2, 0, 5, 10), lower = 0, upper = 5)
#' @export
clip <- function(x, lower = -Inf, upper = Inf) {
  x[x < lower] <- lower
  x[x > upper] <- upper
  return(x)
} 