## To use UnsafeArray: call inside R
## jlinclude(Rulia::RCall)

toR.RObject <- function(obj) {
    jl(`setindex!`)(RCall.Const.GlobalEnv, obj, ".Last.value")
    .Last.value
}

toR.Ptr <- function(obj) {
    jl(`setindex!`)(RCall.Const.GlobalEnv, obj, ".Last.value")
    .Last.value
}

toR.double <- toR.integer <- toR.logical <- toR.complex <-function(obj, envir = globalenv()) {
    symb <- deparse(substitute(obj))
    #jlval <- jlcall("RCall.unsafe_array",jlcall("getfield", jlcall("reval", jlsymbol(symb)), jlsymbol("p")))
    jlval <- jlcall("RCallPtr.reval_unprotected_vector", jlsymbol(symb))
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

toR.factor  <-function(obj, envir = globalenv()) {
    symb <- deparse(substitute(obj))
    #jlval <- jlcall("RCall.unsafe_array",jlcall("getfield", jlcall("reval", jlsymbol(symb)), jlsymbol("p")))
    jlval <- jlcall("RCallPtr.reval_unprotected_factor", jlsymbol(symb))
    class(jlval) <- c("UnsafeCategoricalArray", "UnsafeArray", class(jlval))
    jlval
}

# `[.UnsafeCategoricalArray` <- function(jlval, index) {
#     jlcall("getindex", jlval, as.integer(index))
# }

# `[<-.UnsafeCategoricalArray` <- function(jlval, index, value) {
#     jlcall("setindex!", jlval, value, as.integer(index))
#     jlval
# }

toR.data.frame  <-function(obj, envir = globalenv()) {
    symb <- deparse(substitute(obj))
    #jlval <- jlcall("RCall.unsafe_array",jlcall("getfield", jlcall("reval", jlsymbol(symb)), jlsymbol("p")))
    jlval <- jlcall("RCallPtr.reval_unprotected_dataframe", jlsymbol(symb))
    class(jlval) <- c("UnsafeDataFrame", class(jlval))
    jlval
}

