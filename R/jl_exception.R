jlvalue_or_jlexception <-  function(code, jlval) { 
    if( toR(jlvalue_call("<:", jlvalue_call("typeof", jlval), jlvalue_eval("Exception")))) {
        jlexception(code, jlval)
    } else {
        attr(jlval, "code") <- code
        if(is.jlfunction(jlval)) {
            jlfunction(jlval,parent_envir=parent.frame())
        } else {
            jlvalue_invisible(jlval)
        }
        ##jlval
    }
 }

jlexception <- function(code, jlval) {
     exc <- list(
        code = code,
        err = jlval
    )
    class(exc) <- c(toR(jlvalue_call("string", jlvalue_call("typeof",jlval))) , "jlexception")
    exc
}

jlvalue.jlexception <- function(jlex) jlex$err

print.jlexception <- function(obj, ...) {
    cat("Julia Exception:",class(obj)[[1]],"\n")
}

summary.jlexception <- function(obj) {
    cat("Julia Exception:",class(obj)[[1]],"\n")
    jlvalue_call("showerror", jlvalue_eval("stdout"), obj$err)
    invisible(cat("\n"))
    # cat(toR(jlstring(obj$err)),"\n")
}

is.jlexception <- function(exc) inherits(exc, "jlexception")

jlexceptions <- function(excs) {
    excs <- excs[sapply(excs, is.jlexception)]
    class(excs) <- "jlexceptions"
    excs
}

print.jlexceptions <- function(obj, ...) {
    for(exc in obj) {
        print(exc)
    }
}

summary.jlexceptions <- function(obj) {
    for(exc in obj) {
        summary(exc)
    }
}