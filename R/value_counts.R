#' Count unique values in a vector
#'
#' Returns a data frame with unique values and their counts, sorted by count (descending).
#'
#' @param x A vector (numeric, character, factor, etc.)
#' @return A data frame with columns "value" and "count".
#' @examples
#' value_counts(c("a", "b", "a", "c", "b", "a"))
#' @export
value_counts <- function(x) {
  if (length(x) == 0) {
    return(
      data.frame(
        value = character(0),
        count = integer(0),
        stringsAsFactors = FALSE
      )
    )
  }
  tbl <- as.data.frame(table(x, useNA = "ifany"), stringsAsFactors = FALSE)
  colnames(tbl) <- c("value", "count")
  # Convert "NA" string in value column back to NA
  tbl$value[tbl$value == "<NA>"] <- NA
  tbl <- tbl[order(-tbl$count), ]
  rownames(tbl) <- NULL
  tbl
} 