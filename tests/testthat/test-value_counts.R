library(testthat)
library(pytools)

test_that("value_counts works for basic input", {
  x <- c('a', 'b', 'a', 'c', 'b', 'a')
  res <- value_counts(x)
  expect_equal(res$value, c('a', 'b', 'c'))
  expect_equal(res$count, c(3, 2, 1))
})

test_that("value_counts handles empty input", {
  res <- value_counts(character(0))
  expect_equal(nrow(res), 0)
})

test_that("value_counts handles NA", {
  x <- c('a', NA, 'a', NA)
  res <- value_counts(x)
  expect_true(any(is.na(res$value)))
}) 