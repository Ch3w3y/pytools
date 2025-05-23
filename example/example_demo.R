library(pytools)
library(tidyverse)


data <- read_csv("text_classification_data.csv")

# Load the model
clf <- load_transformer(
  model_name = "cardiffnlp/twitter-roberta-base-sentiment-latest",
  task = "classification"
)

# Classify and bind results
results <- as_tibble(clf$classify(data$text))
label_map <- c("negative" = "Negative", "neutral" = "Neutral", "positive" = "Positive")
results <- results %>%
  mutate(sentiment_label = label_map[label])

data <- bind_cols(data, results %>% select(sentiment_label, sentiment_score = score))

print(data)
