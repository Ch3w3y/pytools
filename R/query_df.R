#' Query a data frame with a string expression
#'
#' Filter rows of a data frame using a string expression (like pandas.DataFrame.query).
#'
#' @param df A data frame.
#' @param expr A string expression to evaluate in the context of the data frame.
#' @return A filtered data frame.
#' @examples
#' df <- data.frame(a = 1:5, b = 6:10)
#' query_df(df, "a > 2 & b < 10")
#' @export
query_df <- function(df, expr) {
  rows <- eval(parse(text = expr), envir = df)
  df[rows, , drop = FALSE]
} 