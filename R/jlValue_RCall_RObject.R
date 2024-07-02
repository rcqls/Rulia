toR.double <- toR.integer <- toR.logical <- toR.character <-function(obj, envir = globalenv()) {
    symb <- deparse(substitute(obj))
    jlval <- jlcall("RCall.unsafe_array",jlcall("getfield", jlcall("reval", jlsymbol(symb)), jlsymbol("p")))
    class(jlval) <- c("UnsafeArray", class(jlval))
    jlval
}

`[.UnsafeArray` <- function(jlval, index) {
    jlcall("getindex", jlval, as.integer(index))
}

`[<-.UnsafeArray` <- function(jlval, index, value) {
    jlcall("setindex!", jlval, value, as.integer(index))
    jlval
}

