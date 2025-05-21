library(testthat)
library(pytools)

test_that("query_df filters rows correctly", {
  df <- data.frame(a = 1:5, b = 6:10)
  res <- query_df(df, 'a > 2 & b < 10')
  expect_equal(res$a, 3:4)
})

test_that("query_df returns empty for no matches", {
  df <- data.frame(a = 1:5)
  res <- query_df(df, 'a > 10')
  expect_equal(nrow(res), 0)
})

test_that("query_df errors on invalid expression", {
  df <- data.frame(a = 1:5)
  expect_error(query_df(df, 'not_a_column > 2'))
}) 