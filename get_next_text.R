
get_next_text <- function(input_text){
  model <- load_model_hdf5('input/full_model_nietzche.h5')
  #pad left to make 40 character
  sentence <- str_pad(string = input_text, width = 40, side = "left")
  generated <- "this is the hello world"
  
  # for(i in 1:400){
  #   
  #   x <- sapply(chars, function(x){
  #     as.integer(x == sentence)
  #   })
  #   x <- array_reshape(x, c(1, dim(x)))
  #   
  #   preds <- predict(model, x)
  #   next_index <- sample_mod(preds, diversity)
  #   next_char <- chars[next_index]
  #   
  #   generated <- str_c(generated, next_char, collapse = "")
  #   sentence <- c(sentence[-1], next_char)
  # }

  return(generated)
}