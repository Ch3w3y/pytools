library(testthat)
library(pytools)

test_that("clip limits values correctly", {
  x <- c(-2, 0, 5, 10)
  expect_equal(clip(x, lower = 0, upper = 5), c(0, 0, 5, 5))
})

test_that("clip handles no limits", {
  x <- c(-2, 0, 5, 10)
  expect_equal(clip(x), x)
})

test_that("clip handles NA", {
  x <- c(1, NA, 3)
  expect_equal(clip(x, lower = 2), c(2, NA, 3))
}) 