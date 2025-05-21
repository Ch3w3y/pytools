#' pytools: Pythonic Data Science Tools for R
#'
#' Provides data manipulation and machine learning utilities inspired by Python's pandas and Hugging Face transformers, including value_counts, clip, explode, cut_bins, query_df, and seamless access to state-of-the-art NLP models via reticulate.
#'
#' @docType package
#' @name pytools
#' @details
#' Main features:
#' - Pythonic data manipulation helpers (value_counts, clip, explode, cut_bins, query_df)
#' - Unified interface to Hugging Face transformer models for embedding, classification, summarization, question answering, translation (including batch), and image generation
#' - Robust error handling and device selection (CPU/GPU)
#' - Designed for extensibility and ease of use
#'
#' See function documentation and README for usage examples.
#'
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  missing <- c()
  if (!requireNamespace("reticulate", quietly = TRUE)) return()
  if (!reticulate::py_module_available('transformers')) missing <- c(missing, 'transformers')
  if (!reticulate::py_module_available('torch')) missing <- c(missing, 'torch')
  if (length(missing) > 0) {
    packageStartupMessage(
      paste0(
        "Python package(s) ", paste(missing, collapse = ', '),
        " not found. Install with reticulate::py_install(c('transformers', 'torch'))."
      )
    )
  }
}

#' Install Python dependencies for pytools
#'
#' Installs the required Python packages using reticulate.
#' @param envname The name of the Python environment to install into (optional).
#' @export
install_pytools_python_deps <- function(envname = NULL) {
  pkgs <- c("transformers", "torch")
  reticulate::py_install(pkgs, envname = envname)
} 