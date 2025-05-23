#' Load a Hugging Face transformer model for inference (robust version)
#'
#' Loads a transformer model and tokenizer using Python's transformers via reticulate.
#' Provides methods for embedding text, classification, summarization, question answering, translation (including batch translation), and image generation, with device selection and error handling.
#'
#' @param model_name The Hugging Face model name (e.g., "distilbert-base-uncased").
#' @param device Device to use: "cpu", "cuda", or "auto" (default: "auto").
#' @param task Task type: "text", "classification", "summarization", "question-answering", "translation", or "image-generation".
#' @return An object with methods for the selected task(s).
#' @examples
#' \dontrun{
#' # Embedding
#' model <- load_transformer("distilbert-base-uncased", device = "auto")
#' emb <- model$embed(c("Hello world!", "Another sentence."))
#' # Classification
#' clf <- load_transformer("distilbert-base-uncased-finetuned-sst-2-english", task = "classification")
#' clf$classify("I love R!")
#' # Summarization
#' summ <- load_transformer("facebook/bart-large-cnn", task = "summarization")
#' summ$summarize("Long text to summarize ...")
#' # Question Answering
#' qa <- load_transformer("distilbert-base-cased-distilled-squad", task = "question-answering")
#' qa$answer(question = "What is the capital of France?", context = "Paris is the capital of France.")
#' # English to Welsh translation (single and batch)
#' trans <- load_transformer("Helsinki-NLP/opus-mt-en-cy", task = "translation")
#' trans$translate("Hello, how are you?")
#' # Batch translation from a data frame column
#' df <- data.frame(text = c("Hello", "How are you?", NA))
#' trans$translate(df$text)
#' }
#' @export
load_transformer <- function(model_name = 'distilbert-base-uncased', device = 'auto', task = 'text') {
  # Check for reticulate
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    stop("The 'reticulate' package is required. Please install it.")
  }
  # Check for transformers and torch in Python
  have_transformers <- reticulate::py_module_available('transformers')
  have_torch <- reticulate::py_module_available('torch')
  if (!have_transformers) stop("Python package 'transformers' not found. Please install it in your Python environment.")
  if (!have_torch) stop("Python package 'torch' not found. Please install it in your Python environment.")

  transformers <- reticulate::import('transformers')
  torch <- reticulate::import('torch')

  # Device selection
  if (device == 'auto') {
    device <- if (torch$cuda$is_available()) 'cuda' else 'cpu'
  }
  if (!(device %in% c('cpu', 'cuda'))) stop("device must be 'cpu', 'cuda', or 'auto'")

  # Try loading model/tokenizer/pipeline
  embed <- NULL
  generate <- NULL
  classify <- NULL
  summarize <- NULL
  answer <- NULL
  translate <- NULL

  tryCatch({
    if (task == 'text') {
      tokenizer <- transformers$AutoTokenizer$from_pretrained(model_name)
      model <- transformers$AutoModel$from_pretrained(model_name)
      model$to(device)
      embed <- function(texts) {
        if (is.character(texts)) {
          texts <- as.list(texts)
        }
        inputs <- tokenizer(texts, return_tensors='pt', padding=TRUE, truncation=TRUE)
        inputs <- lapply(inputs, function(x) x$to(device))
        with(reticulate::py_capture_output(), {
          outputs <- model$forward(
            input_ids = inputs$input_ids,
            attention_mask = inputs$attention_mask
          )
        })
        embeddings <- as.matrix(outputs$last_hidden_state[,1,])
        rownames(embeddings) <- NULL
        embeddings
      }
    } else if (task == 'classification') {
      pipe <- transformers$pipeline('text-classification', model = model_name, device = ifelse(device == 'cuda', 0L, -1L))
      classify <- function(texts) {
        if (is.character(texts)) {
          texts <- as.list(texts)
        }
        results <- pipe(texts)
        if (length(results) == 1) {
          results <- list(results)
        }
        do.call(rbind, lapply(results, function(res) {
          data.frame(label = res$label, score = res$score, stringsAsFactors = FALSE)
        }))
      }
    } else if (task == 'summarization') {
      pipe <- transformers$pipeline('summarization', model = model_name, device = ifelse(device == 'cuda', 0L, -1L))
      summarize <- function(texts) {
        if (is.character(texts)) {
          texts <- as.list(texts)
        }
        results <- pipe(texts)
        if (length(results) == 1) {
          results <- list(results)
        }
        do.call(rbind, lapply(results, function(res) {
          data.frame(summary_text = res$summary_text, stringsAsFactors = FALSE)
        }))
      }
    } else if (task == 'question-answering') {
      pipe <- transformers$pipeline('question-answering', model = model_name, device = ifelse(device == 'cuda', 0L, -1L))
      answer <- function(question, context) {
        if (length(question) != 1 || length(context) != 1) {
          stop('Please provide a single question and a single context.')
        }
        result <- pipe(list(question = question, context = context))
        data.frame(answer = result$answer, score = result$score, start = result$start, end = result$end, stringsAsFactors = FALSE)
      }
    } else if (task == 'translation') {
      # Try to infer the translation direction from the model name
      # e.g., Helsinki-NLP/opus-mt-en-cy -> translation_en_to_cy
      pipe_task <- NULL
      if (grepl('en[-_](to)?[-_]cy', model_name, ignore.case = TRUE)) {
        pipe_task <- 'translation_en_to_cy'
      }
      if (is.null(pipe_task)) {
        # Default to generic translation
        pipe_task <- 'translation'
      }
      pipe <- transformers$pipeline(pipe_task, model = model_name, device = ifelse(device == 'cuda', 0L, -1L))
      translate <- function(texts) {
        # Input validation
        if (is.data.frame(texts) && ncol(texts) == 1) {
          texts <- texts[[1]]
        }
        if (!is.character(texts)) {
          stop("Input to translate() must be a character vector or a single-column data frame.")
        }
        if (length(texts) == 0) {
          return(data.frame(translation_text = character(0), stringsAsFactors = FALSE))
        }
        # Remove NA values and keep track of their positions
        na_idx <- which(is.na(texts))
        texts_no_na <- texts
        texts_no_na[na_idx] <- ""
        results <- pipe(as.list(texts_no_na))
        if (length(results) == 1) {
          results <- list(results)
        }
        out <- do.call(rbind, lapply(results, function(res) {
          data.frame(translation_text = res$translation_text, stringsAsFactors = FALSE)
        }))
        # Restore NA for originally missing values
        if (length(na_idx) > 0) {
          out$translation_text[na_idx] <- NA_character_
        }
        rownames(out) <- NULL
        out
      }
    } else if (task == 'image-generation') {
      pipeline <- transformers$pipeline('text-to-image', model = model_name, device = ifelse(device == 'cuda', 0L, -1L))
      generate <- function(prompt) {
        if (is.null(pipeline)) stop("Image generation pipeline not loaded.")
        result <- pipeline(prompt)
        result[[1]]$image
      }
    } else {
      stop("Unknown task: ", task)
    }
  }, error = function(e) {
    stop("Failed to load model/tokenizer/pipeline: ", e$message)
  })

  structure(list(
    embed = embed,
    classify = classify,
    summarize = summarize,
    answer = answer,
    translate = translate,
    generate = generate,
    device = device,
    model_name = model_name,
    task = task
  ), class = 'TransformerModel')
} 