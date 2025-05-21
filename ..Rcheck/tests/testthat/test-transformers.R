library(testthat)
library(pytools)

skip_if_not_installed("reticulate")
skip_on_cran()

skip_if_no_python <- function() {
  if (!reticulate::py_available(initialize = FALSE)) {
    skip("Python not available")
  }
  if (!reticulate::py_module_available("transformers")) {
    skip("transformers not available in Python")
  }
  if (!reticulate::py_module_available("torch")) {
    skip("torch not available in Python")
  }
}

test_that("load_transformer returns correct class and methods", {
  skip_if_no_python()
  model <- load_transformer("distilbert-base-uncased", device = "cpu")
  expect_s3_class(model, "TransformerModel")
  expect_true(is.function(model$embed))
})

test_that("embed returns matrix of correct shape", {
  skip_if_no_python()
  model <- load_transformer("distilbert-base-uncased", device = "cpu")
  emb <- model$embed(c("Hello", "World"))
  expect_type(emb, "double")
  expect_equal(nrow(emb), 2)
})

test_that("classification pipeline works", {
  skip_if_no_python()
  clf <- load_transformer("distilbert-base-uncased-finetuned-sst-2-english", task = "classification", device = "cpu")
  res <- clf$classify("I love R!")
  expect_true("label" %in% names(res))
  expect_true("score" %in% names(res))
})

test_that("summarization pipeline works", {
  skip_if_no_python()
  summ <- load_transformer("sshleifer/distilbart-cnn-12-6", task = "summarization", device = "cpu")
  res <- summ$summarize("This is a long text that needs to be summarized.")
  expect_true("summary_text" %in% names(res))
})

test_that("question answering pipeline works", {
  skip_if_no_python()
  qa <- load_transformer("distilbert-base-cased-distilled-squad", task = "question-answering", device = "cpu")
  res <- qa$answer(question = "What is the capital of France?", context = "Paris is the capital of France.")
  expect_true("answer" %in% names(res))
})

test_that("batch translation works", {
  skip_if_no_python()
  trans <- load_transformer("Helsinki-NLP/opus-mt-en-cy", task = "translation", device = "cpu")
  texts <- c("Hello", "How are you?", NA)
  res <- trans$translate(texts)
  expect_equal(nrow(res), 3)
  expect_true("translation_text" %in% names(res))
  expect_true(is.na(res$translation_text[3]))
}) 