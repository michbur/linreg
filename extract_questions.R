#extracts questions
extract_questions <- function(file) {
  require(dplyr)
  all_lines <- readLines(file)
  all_lines[grep("[Q", all_lines, fixed = TRUE)] %>% 
    strsplit("[Q", fixed = TRUE) %>%
    sapply(function(i) i[2]) %>%
    strsplit("]", fixed = TRUE) %>%
    sapply(function(i) i[1]) %>%
    sub("<br/> ", "", ., fixed = TRUE) %>%
    paste0("Q", ., "    \n")
}
