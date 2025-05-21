library(testthat)
library(pytools)

test_that("explode works for basic list-column", {
  df <- data.frame(a = 1:2, b = I(list(1:2, 3:4)))
  res <- explode(df, b)
  expect_equal(nrow(res), 4)
  expect_equal(res$a, c(1, 1, 2, 2))
  expect_equal(res$b, c(1, 2, 3, 4))
})

test_that("explode handles empty lists", {
  df <- data.frame(a = 1, b = I(list(integer(0))))
  res <- explode(df, b)
  expect_equal(nrow(res), 0)
})

test_that("explode handles NA in list-column", {
  df <- data.frame(a = 1, b = I(list(NA)))
  res <- explode(df, b)
  expect_equal(nrow(res), 1)
  expect_true(is.na(res$b))
}) 