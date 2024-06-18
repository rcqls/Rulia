is.variable <- function(name, envir) {
    exists(name,envir=envir) && !is.function(eval(parse(text = name), envir = envir))
}