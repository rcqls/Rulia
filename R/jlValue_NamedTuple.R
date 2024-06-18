##TODO: toR

jlNamedTuple <- function(...) {
    obj <- list(...)
    .RNamedList2jlNamedTuple(obj)
}

toR.NamedTuple <- function(jlval) {
    obj <- list()
    for (nm in names(jlval)) {
        obj[[nm]] <- toR(jlval[nm])
    }
    return(obj)
}

names.NamedTuple <- function(jlval) jlvalue_callR("keys",jlval)

"[.NamedTuple" <- function(jlval, field) {
     if (field %in% names(jlval)) {
        jlvalue_call("getfield",jlval,jlsymbol(field))
    } else {
        NULL
    }
}

"$.NamedTuple" <- function(jlval, field) jlval[field]