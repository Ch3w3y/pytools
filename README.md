# pytools: Pythonic Data Science Tools for R

**pytools** brings Python-inspired data science and machine learning features to R, including convenient data manipulation helpers and seamless access to Hugging Face transformer models for NLP and image generation.

## Features
- Pythonic data manipulation: `value_counts`, `clip`, `explode`, `cut_bins`, `query_df`
- Unified interface to Hugging Face transformers for:
  - Text embedding
  - Classification
  - Summarization
  - Question answering
  - Translation (including batch translation)
  - Image generation
- Robust error handling and device selection (CPU/GPU)

## Installation

```r
# Install from GitHub (requires devtools)
# install.packages("devtools")
devtools::install_github("Ch3w3y/pytools")
```

**Python dependencies:**

For transformer features, you must have Python with the `transformers` and `torch` packages installed. The easiest way is to run:

```r
# Install Python dependencies using the helper function
pytools::install_pytools_python_deps()
```

Alternatively, you can use:

```r
reticulate::py_install(c("transformers", "torch"))
```

or in your Python environment:

```sh
pip install transformers torch
```

## Usage

```r
library(pytools)

# Data manipulation
value_counts(c('a', 'b', 'a', 'c', 'b', 'a'))
clip(c(-2, 0, 5, 10), lower = 0, upper = 5)
df <- data.frame(a = 1:2, b = I(list(1:2, 3:4)))
explode(df, b)
cut_bins(1:10, bins = 3)
query_df(data.frame(a = 1:5, b = 6:10), 'a > 2 & b < 10')

# Transformer models
# Embedding
model <- load_transformer('distilbert-base-uncased', device = 'auto')
emb <- model$embed(c('Hello world!', 'Another sentence.'))

# Classification
clf <- load_transformer('distilbert-base-uncased-finetuned-sst-2-english', task = 'classification')
clf$classify('I love R!')

# Summarization
summ <- load_transformer('facebook/bart-large-cnn', task = 'summarization')
summ$summarize('Long text to summarize ...')

# Question Answering
qa <- load_transformer('distilbert-base-cased-distilled-squad', task = 'question-answering')
qa$answer(question = 'What is the capital of France?', context = 'Paris is the capital of France.')

# English to Welsh translation (single and batch)
trans <- load_transformer('Helsinki-NLP/opus-mt-en-cy', task = 'translation')
trans$translate('Hello, how are you?')
df <- data.frame(text = c('Hello', 'How are you?', NA))
trans$translate(df$text)

# Image generation (if supported by model)
# img_model <- load_transformer('CompVis/stable-diffusion-v1-4', task = 'image-generation', device = 'cuda')
# img <- img_model$generate('A cat riding a bicycle')
```

## Contributing
Pull requests and issues are welcome! Please ensure new features are well-documented and tested.

- Fork the repository and create a feature branch.
- Add tests and documentation for new features.
- Run `devtools::check()` to ensure all checks pass.
- Open a pull request with a clear description of your changes.

## Getting Help
- For package issues, open a GitHub issue.
- For Python/reticulate issues, see the [reticulate documentation](https://rstudio.github.io/reticulate/).

## License
MIT 
