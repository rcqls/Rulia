jlDataFrame <- function(...) {
    df <- list(...)
    ## TODO: check if elements of df have same dimension
    .RNamedList2jlDataFrame(df)
}

toR.DataFrame <- function(jlval) {
    nms <- toR(jlvalue_call("names",jlval))
    res <- list()
    for(nm in nms) {
        res[[nm]] <- jlvalue_callR("getindex",jlval, jlcolon(), jlsymbol(nm))
    }
    attr(res,"row.names") <- as.character(seq(1,length=length(res[[1]])))
    class(res) <- "data.frame"
    res
}

names.DataFrame <- function(jlval) jlvalue_callR("names",jlval)

"[.DataFrame" <- function(jlval, i, field) {
    if(missing(field)) {
        field <- i
        i <- jlcolon()
    } else {
        i <- jleval(as.character(i))
    }
    if (field %in% names(jlval)) {
        jlvalue_call("getindex",jlval, i, jlsymbol(field))
    } else {
        NULL
    }
}

"$.DataFrame" <- function(jlval, field) jlval[field]