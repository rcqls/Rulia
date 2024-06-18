## N.B.
## jlvalue_<func> use jlvalue_call
## when jl<func> use jltrycall


jlsymbol <- function(field) {
    if(!.jlrunning()) .jlinit()
    res <- .External("Rulia_jl_symbol", field, PACKAGE = "Rulia")
    res
}

jlcolon <- function() jlvalue_eval(":")

jlisstructtype <- function(jlval) {
    jltrycall("isstructtype", jlval)
}
jlvalue_isstructtype <- function(jlval) {
    jlvalue_call("isstructtype", jlval)
}

jltypeof <- function(jlval) {
    jltrycall("typeof", jlval)
}
jlvalue_typeof <- function(jlval) {
    if(!.jlrunning()) .jlinit()
    # res <- .External("Rulia_typeof2R", jlval, PACKAGE = "Rulia")
    jlvalue_call("typeof", jlval)
}

jlfieldnames <- function(jlval) {
    jltrycall("fieldnames", jlvalue_call("typeof", jlval))
}
jlvalue_fieldnames <- function(jlval) {
    jlvalue_call("fieldnames", jlvalue_call("typeof", jlval))
}

jlgetfield <- function(jlval, field) {
    jltrycall("getfield", jlval, jlsymbol(field))
}
jlvalue_getfield <- function(jlval, field) {
    jlvalue_call("getfield", jlval, jlsymbol(field))
}

jlstring <- function(jlval) jltrycall("string", jlval)
jlvalue_string <- function(jlval) jlvalue_call("string", jlval)


jltypeofR <- function(jlval) jlstringR(jltypeof(jlval))
jlstringR <- function(jlval) toR(jlstring(jlval))
jlisstructtypeR <- function(jlval) toR(jlisstructtype(jlval))
jlfieldnamesR <- function(jlval) toR(jlfieldnames(jlval))
jlgetfieldR <- function(jlval, field) toR(jlgetfield(jlval, field))

jlshow <- function(jlval) invisible(jltrycall("show",jlval))
jldisplay <- function(jlval) invisible(jltrycall("display",jlval))

"%<:%" <- function(a, b) {args <- Rulia:::jl_rexprs2(substitute(list(a,b)), parent_envir=parent.frame());jl(`<:`)(args[[1]],args[[2]])}

"%isa%" <- function(a, b) {args <- Rulia:::jl_rexprs2(substitute(list(a,b)), parent_envir=parent.frame());jl(isa)(args[[1]],args[[2]])}

expect_jlequal <- function(jlval, res, ...) expect_equal(Rulia:::jlvalue_capture_display(jlval), paste0(res, "\n"), ...)