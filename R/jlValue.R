jlvalue <- function(obj, ...) UseMethod("jlvalue", obj)

jlvalue.default <- function(expr, ...) {
  warning(paste0("No jlvalue conversion for ", expr, " !"))
  NULL
}

## add code as attribute
jlvalue_with_code <- function(jlval, code) {
    attr(jlval, "code") <- code
    return(jlval)
}

########################
## eval functions
## 1) jlvalue mode 
## IMPORTANT: the user knows that the argument is a character and the content is a valid julia code
jlvalue_eval <- function(expr) {
    .jlvalue_eval_with_class(expr)
}

## 2) jl mode: test on length on obj and jlexception 
jleval <- function(obj, ...) {
    if (length(obj) == 1 && is.character(obj)) {
        jlval <- .jlvalue_eval_with_class(obj)
        jlvalue_with_exception(obj, jlval)
    } else {
        warning("Bad input for jlvalue_eval function!")
        NULL
    }
}

jlvalue_invisible <- function(jlval) {
    if(jlvalue_callR("isnothing", jlval)) {
        invisible(jlval)
    } else {
        jlval
    }
}

jlvalue.jlvalue <- function(jlval, ...) jlval

## used to evaluate jl(as.name("<julia expresssion>"))
jlvalue.name <- function(name) jleval(deparse(name))

is.jlvalue <- function(obj) inherits(obj,"jlvalue")

print.jlvalue <- function(jlval, ...) {
    if (interactive()) {
        invisible(jlvalue_show_display(jlval))
    } else {
        cat(jlvalue_capture_display(jlval))
    }
}

toR.jlvalue <- function(jlval) {
    res <- .jlvalue2R(jlval)
    if (typeof(res) == "externalptr") {
        res
    } else {
        if (is.list(res) && any(sapply(res,is.jlvalue))) {
            sapply(res, toR)
        } else {
            if (is.list(res)) simplify2array(res) else res
        }
    }
}