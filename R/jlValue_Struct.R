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

names.Struct <- function(jlval) list(type=R(jlvalue_typeof(jlval)), fields=unlist(jlfieldnamesR(jlval)))

"[.Struct" <- function(jlval, field) {
    if (field %in% names(jlval)$fields) {
        jlgetfield(jlval, field)
    } else {
        NULL
    }
}

"$.Struct" <- function(jlval, field) jlval[field]

toR.Struct <- function(jlval) {
    obj <- list()
    for(field in names(jlval)$fields){
        obj[[field]] <- toR(jlval[field])
    }
    class(obj) <- c("jlStruct", paste0("jl",class(jlval)[1]))
    obj
}

## Symbol is a Struct in Julia so this is required
toR.Symbol <- function(jlval) toR.jlvalue(jlval)