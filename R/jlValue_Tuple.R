jlTuple <- function(...) {
    obj <- list(...)
    .RList2jlTuple(obj)
}

toR.Tuple <- function(jlval) {
    obj <- list()
    for (i in seq(1, length=length(jlval))) {
        obj[[i]] <- toR(jlval[i])
    }
    return(obj)
}

length.Tuple <- function(jlval) jlvalue_callR("length", jlval)

"[.Tuple" <- function(jlval, ind) {
     if (ind %in% seq(1, length(jlval))) {
        jlvalue_call("getindex", jlval, jl(as.integer(ind)))
    } else {
        NULL
    }
}