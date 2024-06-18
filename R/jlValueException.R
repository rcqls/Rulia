jlvalue_with_exception <-  function(code, jlval) { 
    if( toR(jlvalue_call("<:", jlvalue_call("typeof", jlval), jlvalue_eval("Exception")))) {
        jlexception(code, jlval)
    } else {
        jlval
    }
 }

jlexception <- function(code, jlval) {
    jlval <- jlvalue_with_code(jlval, code)
    class(jlval) <- c(toR(jlvalue_call("string", jlvalue_call("typeof",jlval))) , "jlexception", "jlvalue")
    jlval
}

jlvalue.jlexception <- function(jlval) jlval


print.jlexception <- function(jlval, ...) {
    cat("Julia Exception:", class(jlval)[[1]],"\n")
}

summary.jlexception <- function(jlval) {
    cat("Julia Exception:",class(jlval)[[1]],"\n")
    jlvalue_call("showerror", jlvalue_eval("stdout"), jlval)
    invisible(cat("\n"))
    # cat(toR(jlstring(obj$err)),"\n")
}

is.jlexception <- function(jlval) inherits(jlval, "jlexception")

jlexceptions <- function(jlvals) {
    jlvals <- jlvals[sapply(jlvals, is.jlexception)]
    class(jlvals) <- "jlexceptions"
    jlvals
}

print.jlexceptions <- function(jlvals, ...) {
    for(jlval in jlvals) {
        print(jlval)
    }
}

summary.jlexceptions <- function(jlvals) {
    for(jlval in jlvals) {
        summary(jlval)
    }
}