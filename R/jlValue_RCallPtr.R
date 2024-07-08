## To use UnsafeArray: call inisde R
## jlinclude("RCallPtr.jl",package="Rulia")

toR.double <- toR.integer <- toR.logical <- toR.character <-function(obj, envir = globalenv()) {
    symb <- deparse(substitute(obj))
    #jlval <- jlcall("RCall.unsafe_array",jlcall("getfield", jlcall("reval", jlsymbol(symb)), jlsymbol("p")))
    jlval <- jlcall("RCallPtr.reval_unprotected", jlsymbol(symb))
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
