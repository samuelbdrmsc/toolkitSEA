

# ================
# 0. Set file path
# ================
csv_path <- "C:/Users/HP/Downloads/country_wise_latest.csv"  # <- change if needed

# ================
# 1. Read data
# ================
df <- read.csv(csv_path, stringsAsFactors = FALSE, check.names = FALSE)
cat("Loaded:", csv_path, " | Rows:", nrow(df), " | Cols:", ncol(df), "\n")

# ================
# 2. Prepare / clean
# ================
# Normalize column names
names(df) <- tolower(names(df))
names(df) <- gsub("[^a-z0-9_]", "_", names(df))
names(df) <- gsub("_+", "_", names(df))

# Show available column names
cat("Columns:", paste(names(df), collapse = ", "), "\n")

# Helper to coerce numeric safely and report bad rows
safe_num <- function(x, colname) {
  orig <- as.character(x)
  cleaned <- gsub(",", "", orig)
  num <- suppressWarnings(as.numeric(cleaned))
  bad_idx <- which(is.na(num) & !is.na(orig) & orig != "")
  if (length(bad_idx) > 0) {
    cat(sprintf("Warning: %d non-numeric entries found in '%s'. Showing up to 10 examples:\n", length(bad_idx), colname))
    print(head(data.frame(row = bad_idx, value = orig[bad_idx]), 10))
  }
  return(num)
}

# Columns we expect (common names)
expected <- c("country", "confirmed", "deaths", "recovered", "active", "new_cases")

# If country column missing, try to pick first text-like column
if (!("country" %in% names(df))) {
  textcols <- names(df)[sapply(df, function(x) sum(!is.na(x) & nchar(as.character(x))>0) > 0)]
  names(df)[1] <- "country"
  cat("Note: renamed first column to 'country'.\n")
}

# Convert numeric columns if present
for (col in c("confirmed", "deaths", "recovered", "active", "new_cases")) {
  if (col %in% names(df)) {
    df[[col]] <- safe_num(df[[col]], col)
  } else {
    cat(sprintf("Note: column '%s' not present in data.\n", col))
  }
}

# Recompute CFR (percent)
if (all(c("confirmed", "deaths") %in% names(df))) {
  df$cfr <- ifelse(!is.na(df$confirmed) & df$confirmed > 0,
                   100 * df$deaths / df$confirmed, NA)
} else {
  df$cfr <- NA
}

# Trim country names
if ("country" %in% names(df)) df$country <- trimws(as.character(df$country))

# Quick summary
cat("Numeric summary (non-NA counts):\n")
for (col in c("confirmed", "deaths", "recovered", "active", "new_cases")) {
  if (col %in% names(df)) cat(sprintf(" %s: %d non-NA\n", col, sum(!is.na(df[[col]]))))
}

# ================
# 3. Load libs
# ================
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("scales", quietly = TRUE)) install.packages("scales")
if (!requireNamespace("ggrepel", quietly = TRUE)) install.packages("ggrepel")

library(ggplot2)
library(dplyr)
library(scales)
library(ggrepel)

# ================
# 4. Plot 1: Top 15 Confirmed
# ================
if ("confirmed" %in% names(df) && sum(!is.na(df$confirmed)) >= 1) {
  top15 <- df %>% filter(!is.na(confirmed)) %>% arrange(desc(confirmed)) %>% slice(1:15)
  p1 <- ggplot(top15, aes(x = reorder(country, confirmed), y = confirmed)) +
    geom_col(fill = "steelblue") + coord_flip() +
    scale_y_continuous(labels = comma) +
    labs(title = "Top 15 Countries by Confirmed Cases", x = "", y = "Confirmed") +
    theme_minimal(base_size = 12)
  ggsave("plot_top15_confirmed.png", p1, width = 10, height = 6, dpi = 150)
  cat("Saved: plot_top15_confirmed.png\n")
} else cat("Skipping Plot1 (no confirmed data)\n")

# ================
# 5. Plot 2: Confirmed vs Deaths (log-log)
# ================
if (all(c("confirmed", "deaths") %in% names(df)) && sum(!is.na(df$confirmed & df$deaths)) >= 5) {
  scatter_df <- df %>% filter(!is.na(confirmed) & !is.na(deaths) & confirmed > 0 & deaths >= 0)
  p2 <- ggplot(scatter_df, aes(x = confirmed, y = deaths)) +
    geom_point(alpha = 0.6, size = 2, color = "darkred") +
    scale_x_log10(labels = comma) + scale_y_log10(labels = comma) +
    labs(title = "Confirmed vs Deaths (log scale)", x = "Confirmed (log10)", y = "Deaths (log10)") +
    theme_minimal(base_size = 12)
  top_label <- scatter_df %>% arrange(desc(deaths)) %>% slice(1:8)
  p2 <- p2 + geom_text_repel(data = top_label, aes(label = country), size = 3)
  ggsave("plot_confirmed_vs_deaths.png", p2, width = 10, height = 6, dpi = 150)
  cat("Saved: plot_confirmed_vs_deaths.png\n")
} else cat("Skipping Plot2 (insufficient confirmed/deaths data)\n")

# ================
# 6. Plot 3: Active cases distribution (log10 histogram)
# ================
if ("active" %in% names(df) && sum(!is.na(df$active & df$active>0)) >= 5) {
  p3 <- ggplot(df %>% filter(!is.na(active) & active > 0), aes(x = log10(active))) +
    geom_histogram(bins = 30, fill = "lightgreen", color = "black") +
    labs(title = "Distribution of Active Cases (log10)", x = "log10(active)", y = "Count") +
    theme_minimal(base_size = 12)
  ggsave("plot_active_distribution.png", p3, width = 10, height = 6, dpi = 150)
  cat("Saved: plot_active_distribution.png\n")
} else cat("Skipping Plot3 (insufficient active data)\n")

# ================
# 7. Plot 4: Top 12 CFR (%) (filter confirmed > 1000)
# ================
if ("cfr" %in% names(df) && "confirmed" %in% names(df)) {
  top_cfr <- df %>% filter(!is.na(cfr) & !is.na(confirmed) & confirmed > 1000) %>% arrange(desc(cfr)) %>% slice(1:12)
  if (nrow(top_cfr) > 0) {
    p4 <- ggplot(top_cfr, aes(x = reorder(country, cfr), y = cfr)) +
      geom_col(fill = "tomato") + coord_flip() +
      labs(title = "Top 12 CFR (%) — Countries with > 1000 confirmed", x = "", y = "CFR (%)") +
      theme_minimal(base_size = 12)
    ggsave("plot_top12_cfr.png", p4, width = 10, height = 6, dpi = 150)
    cat("Saved: plot_top12_cfr.png\n")
  } else cat("Skipping Plot4 (no CFR rows after filtering confirmed>1000)\n")
} else cat("Skipping Plot4 (cfr/confirmed missing)\n")

# ================
# 8. Plot 5: Top 10 New cases
# ================
if ("new_cases" %in% names(df) && sum(!is.na(df$new_cases)) >= 1) {
  top_new <- df %>% filter(!is.na(new_cases)) %>% arrange(desc(new_cases)) %>% slice(1:10)
  if (nrow(top_new) > 0) {
    p5 <- ggplot(top_new, aes(x = reorder(country, new_cases), y = new_cases)) +
      geom_col(fill = "purple") + coord_flip() +
      geom_text(aes(label = scales::comma(new_cases)), hjust = -0.1, size = 3) +
      scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
      labs(title = "Top 10 Countries by New Cases", x = "", y = "New cases") +
      theme_minimal(base_size = 12)
    ggsave("plot_top10_newcases_clean.png", p5, width = 10, height = 6, dpi = 150)
    cat("Saved: plot_top10_newcases_clean.png\n")
  } else cat("Skipping Plot5 (no non-NA new_cases rows)\n")
} else cat("Skipping Plot5 (new_cases missing)\n")

# ================
# Done
# ================
cat("Plotting finished. Check PNG files in your working directory.\n")

getwd()

setwd("C:/Users/HP/Downloads")






