jlArray <- function(...) {
    obj <- c(...)
    jlvalue(obj)
}

length.Array <- function(jlval) {
    jlvalue_callR("length",jlval)
}

"[.Array" <- function(jlval, i) {
    s <- length(jlval)
    if (i > 0 && i <= s) {
        i <- jleval(as.character(i))
        jlres <- jlvalue_call("getindex", jlval, i)
        if(is.Struct(jlres)) {
            class(jlres) <- c(class(jlres)[1], "Struct", class(jlres)[-1])
        }
        jlres
    } else {
        NULL
    }
}

`[.AbstractArray` <- function(jlval, index) {
    jltrycall("getindex", jlval, index)
}

# `[<-.AbstractArray` <- function(jlval, index, value) {
#     jltrycall("setindex!", jlval, value, index)
# }

toR.Array <- function(jlval) {
    res <- toR.jlvalue(jlval)
    if (typeof(res) == "externalptr") {
        sapply(1:length(jlval), function(i) toR(jlval[i]))
    } else {
        res
    }
}