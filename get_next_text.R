
get_next_text <- function(speaker, input_text, diversity = 1, models){
  
  # Helper functions & Results ----------------------------------------------------
  
  sample_mod <- function(preds, temperature = 1){
    preds <- log(preds)/temperature
    exp_preds <- exp(preds)
    preds <- exp_preds/sum(exp(preds))
    
    rmultinom(1, 1, preds) %>% 
      as.integer() %>%
      which.max()
  }
  
  
  #get the file path for the saves model file
  trained_model_file <- as.character(models[which(models[,1] == speaker),][,2])
  model <- load_model_hdf5(paste0('input/',trained_model_file))
  chars_file <- as.character(models[which(models[,1] == speaker),][,3])
  chars <- readRDS(paste0('input/', chars_file))
  #pad left to make 40 character
  sentence <- str_pad(string = input_text, width = 40, side = "left") %>% 
    tokenize_characters(strip_non_alphanum = FALSE, simplify = TRUE)
  generated <- ""
  
  for(i in 1:400){

    x <- sapply(chars, function(x){
      as.integer(x == sentence)
    })
    x <- array_reshape(x, c(1, dim(x)))

    preds <- predict(model, x)
    next_index <- sample_mod(preds, diversity)
    next_char <- chars[next_index]

    generated <- str_c(generated, next_char, collapse = "")
    sentence <- c(sentence[-1], next_char)
  }

  return(generated)
}