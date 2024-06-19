## internals
.jlvalue2R <- function(jlval) {
    ## if(!.jlrunning()) .jlinit()
    res <- .External("Rulia_jlvalue2R", jlval, PACKAGE = "Rulia")
    res
}

## the raw one from the R and julia APIs
.jlvalue_eval <- function(expr) {
  ## if(!.jlrunning()) .jlinit()
  jlval <- .External("Rulia_jlvalue_eval", expr, PACKAGE = "Rulia")
  return(jlval)
}

.jlvalue_eval_with_class <- function(expr) {
  ## if(!.jlrunning()) .jlinit()
  jlval <- .jlvalue_eval(expr)
  if(is.Struct(jlval)) {
    addclass <- "Struct"
    if(jlvalue_callR("isa",jlval,.jlvalue_eval("AbstractArray"))) {
        addclass <- c("AbstractArray", addclass)
    }
    class(jlval) <- c(class(jlval)[1:(length(class(jlval)) - 1)],
        addclass, "jlvalue")
  }
  return(jlval)
}

.jlvalue_trycall <- function(meth, jlargs, jlkwargs = jlvalue_eval("[]")) {
    ## if(!.jlrunning()) .jlinit()
    .External("Rulia_jlvalue_trycall", meth, jlargs, jlkwargs, PACKAGE = "Rulia")
}

.jlvalue_tryfunc <- function(meth, jlargs, jlkwargs = jlvalue_eval("[]")) {
    ## if(!.jlrunning()) .jlinit()
    .External("Rulia_jlvalue_tryfunc", meth, jlargs, jlkwargs, PACKAGE = "Rulia")
}

.jlvalue_call0 <- function(meth) {
    ## if(!.jlrunning()) .jlinit()
    .External("Rulia_jlvalue_call0", meth, PACKAGE = "Rulia")
}

.jlvalue_call1 <- function(meth, jlv) {
    ## if(!.jlrunning()) .jlinit()
    .External("Rulia_jlvalue_call1", meth, jlv, PACKAGE = "Rulia")
}

.jlvalue_func_call1 <- function(jl_meth, jlv) {
    ## if(!.jlrunning()) .jlinit()
    .External("Rulia_jlvalue_func_call1", jl_meth, jlv, PACKAGE = "Rulia")
}

jlvalue_func1 <- function(jl_meth, jlv) .jlvalue_func_call1(jl_meth, jlv)

.jlvalue_call2 <- function(meth, jlv, jlarg) {
    ## if(!.jlrunning()) .jlinit()
    .External("Rulia_jlvalue_call2", meth, jlv, jlarg, PACKAGE = "Rulia")
}

.jlvalue_call3 <- function(meth, jlv, jlarg, jlarg2) {
    ## if(!.jlrunning()) .jlinit()
    .External("Rulia_jlvalue_call3", meth, jlv, jlarg, jlarg2, PACKAGE = "Rulia")
}

.jlvalue_call_ <- function(meth, jlargs, jlnargs) {
    ## if(!.jlrunning()) .jlinit()
    .Call("Rulia_jlvalue_call", meth, jlargs, jlnargs, PACKAGE = "Rulia")
}

.jlvalue_call <- function(meth, ...) {
    jlargs <- list(...)
    jlnargs <- length(jlargs)
    .jlvalue_call_(meth,jlargs,jlnargs)
}

.jlvalue_func_call <- function(jlfunc, jlargs, jlnargs) {
    ## if(!.jlrunning()) .jlinit()
    .Call("Rulia_jlvalue_func_call", jlfunc, jlargs, jlnargs, PACKAGE = "Rulia")
}

jlvalue_func <- function(jlfunc, ...) {
    jlargs <- list(...)
    jlnargs <- length(jlargs)
    .jlvalue_func_call(jlfunc,jlargs,jlnargs)
}

jlvalue_finalize <- function(...) {
  extptrs <- unlist(c(...))
  invisible(.Call("Rulia_finalizeExternalPtr", extptrs, PACKAGE="Rulia"))
}


jlvalue_show_display <- function(jlval, ...) {
    .Call("Rulia_show_preserved_ref", jlval, PACKAGE = "Rulia")
    NULL
}

jlvalue_capture_display <- function(jlval, ...) {
    .Call("Rulia_capture_preserved_ref", jlval, PACKAGE = "Rulia")
}


jlvalue_new_struct <- function(datatype, jlargs, jlnargs) {
    ## if (!.jlrunning()) .jlinit()
    return(.Call("Rulia_jlvalue_new_struct", datatype, jlargs, jlnargs, PACKAGE = "Rulia"))
}


