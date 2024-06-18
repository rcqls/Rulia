jlvalue.factor <- function(fa, ...) {
    jlusing("CategoricalArrays")
    jlvalue_call("categorical", jlvalue(as.character(fa)))
}