jlStruct <- function(datatype, ...) {
    if (!is.character(datatype)) {
        stop("No julia DataType specified!")
    }
    jlargs <- lapply(list(...), jl) # TODO: check if jlvalue is better?
    jlnargs <- length(jlargs)
    jlvalue_new_struct(datatype, jlargs, jlnargs)
}

is.Struct <- function(jlval) {
    R(jlvalue_isstructtype(jlvalue_typeof(jlval)))
}

names.Struct <- function(jlval) list(type=R(jlvalue_typeof(jlval)), fields=jlfieldnamesR(jlvalue_typeof(jlval)))

"[.Struct" <- function(jlval, field) {
    if (field %in% names(jlval)) {
        jlgetfield(jlval,jlsymbol(field))
    } else {
        NULL
    }
}

"$.Struct" <- function(jlval, field) jlval[field]