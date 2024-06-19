## jlvalue_<func> use jlvalue_call


jlsymbol <- jlvalue_symbol <- function(field) {
    if(!.jlrunning()) .jlinit()
    res <- .External("Rulia_jl_symbol", field, PACKAGE = "Rulia")
    res
}

jlcolon <- jlvalue_colon <- function() jlvalue_eval(":")

jlvalue_isstructtype <- function(jlval) {
    jlvalue_call("isstructtype", jlval)
}

jlvalue_typeof <- function(jlval) {
    if(!.jlrunning()) .jlinit()
    # res <- .External("Rulia_typeof2R", jlval, PACKAGE = "Rulia")
    jlvalue_call("typeof", jlval)
}

jlvalue_fieldnames <- function(jlval) {
    jlvalue_call("fieldnames", jlvalue_call("typeof", jlval))
}

jlvalue_getfield <- function(jlval, field) {
    jlvalue_call("getfield", jlval, jlsymbol(field))
}

jlvalue_string <- function(jlval) jlvalue_call("string", jlval)