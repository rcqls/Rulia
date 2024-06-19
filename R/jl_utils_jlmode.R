## Safe functions using jltrycall

jlisstructtype <- function(jlval) {
    jltrycall("isstructtype", jlval)
}

jltypeof <- function(jlval) {
    jltrycall("typeof", jlval)
}

jlfieldnames <- function(jlval) {
    jltrycall("fieldnames", jlvalue_call("typeof", jlval))
}

jlgetfield <- function(jlval, field) {
    jltrycall("getfield", jlval, jlsymbol(field))
}

jlstring <- function(jlval) jltrycall("string", jlval)

jltypeofR <- function(jlval) jlstringR(jltypeof(jlval))
jlstringR <- function(jlval) toR(jlstring(jlval))
jlisstructtypeR <- function(jlval) toR(jlisstructtype(jlval))
jlfieldnamesR <- function(jlval) toR(jlfieldnames(jlval))
jlgetfieldR <- function(jlval, field) toR(jlgetfield(jlval, field))

jlshow <- function(jlval) invisible(jltrycall("show",jlval))
jldisplay <- function(jlval) invisible(jltrycall("display",jlval))

"%<:%" <- function(a, b) {args <- jl_args_rexprs(substitute(list(a,b)), parent_envir=parent.frame());jl(`<:`)(args[[1]],args[[2]])}

"%isa%" <- function(a, b) {args <- jl_args_rexprs(substitute(list(a,b)), parent_envir=parent.frame());jl(isa)(args[[1]],args[[2]])}

expect_jlequal <- function(jlval, res, ...) expect_equal(Rulia:::jlvalue_capture_display(jlval), paste0(res, "\n"), ...)