#' Explode a list-column into long format
#'
#' Turns each element of a list-column into a row, duplicating the other columns as needed.
#'
#' @param df A data frame.
#' @param col The name of the list-column to explode (unquoted).
#' @return A data frame with the list-column exploded into long format.
#' @examples
#' df <- data.frame(a = 1:2, b = I(list(1:2, 3:4)))
#' explode(df, b)
#' @export
explode <- function(df, col) {
  col <- deparse(substitute(col))
  lens <- sapply(df[[col]], length)
  out <- df[rep(seq_len(nrow(df)), lens), , drop = FALSE]
  out[[col]] <- unlist(df[[col]], recursive = FALSE)
  rownames(out) <- NULL
  out
} 