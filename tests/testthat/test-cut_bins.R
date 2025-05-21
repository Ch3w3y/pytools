library(testthat)
library(pytools)

test_that("cut_bins bins numeric data", {
  x <- 1:10
  res <- cut_bins(x, bins = 2)
  expect_equal(length(res), 10)
  expect_true(is.factor(res))
})

test_that("cut_bins works with custom breaks", {
  x <- 1:5
  res <- cut_bins(x, bins = c(0, 2, 5))
  expect_equal(levels(res), c("[0,2]", "(2,5]"))
})

test_that("cut_bins handles NA", {
  x <- c(1, NA, 3)
  res <- cut_bins(x, bins = 2)
  expect_true(any(is.na(res)))
}) 