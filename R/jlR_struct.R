print.jlStruct <- function(obj, ...) {
    print(unclass(obj)) ## as a list
    cat("## from jl: struct ", substring(class(obj)[2],3),"\n", sep="")
}