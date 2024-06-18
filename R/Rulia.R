## IMPORTANT
## 1) jl(`<multiline julia expression>`) redirect to jleval("<multiline julia expression>")
## 2) jl(<R object>) is redirected to jlvalue(<RObject>)


jl <- function(obj, ..., name_class = TRUE) {
  name <- deparse(substitute(obj))
  if( name_class && !is.variable(name, parent.frame())) {
    return(jl_rexpr(substitute(obj), obj, ...))
  }
  jlvalue_with_exception(name, jlvalue(obj, ...))
}

jlR <- function(obj, ..., name_class = TRUE) {
  name <- deparse(substitute(obj))
  if (name_class && !is.variable(name, parent.frame())) {
    res <- jl_rexpr(substitute(obj), ...)
    if (!is.null(res)) return(toR(res))
  }
  toR(jlvalue_with_exception(name, jlvalue(obj, ...)))
}

jl2 <- function(obj, ..., parent_envir = parent.frame(), name_class = TRUE) {
  name <- deparse(substitute(obj))
  if (name_class && !is.variable(name, parent_envir)) {
    return(jl_rexpr2(substitute(obj), parent_envir))
  }
  jlvalue_with_exception(name, jlvalue(obj, ...))
}

jl2R <- function(obj, ..., parent_envir = parent.frame(), name_class = TRUE) {
  if (name_class && !is.variable(name, parent_envir)) {
    res <- jl_rexpr2(substitute(obj), parent_envir)
    if (!is.null(res)) return(toR(res))
  }
  toR(jlvalue(obj, ...))
}

# jlrun_safe <- function(expr) {
#   if(!.jlrunning()) .jlinit()
#   invisible(.External("Rulia_run", .jlsafe(expr), PACKAGE = "Rulia"))
# }

jlrun_ <- function(expr) {
  if(!.jlrunning()) .jlinit()
  invisible(.External("Rulia_run", expr, PACKAGE = "Rulia"))
}

jlrun <- jlrun_with_jlexception <- function(expr) {
  if(!.jlrunning()) .jlinit()
  res <- .External("Rulia_run_with_exception", expr, PACKAGE = "Rulia")
  if(!is.null(res)) {
    res <- jlexception(expr, res)
    summary(res)
  }
  invisible(res)
}

R <- toR <- function(jlval) UseMethod("toR")

toR.default <- function(obj) obj

jlvalue_get <- function(var) {
  if (!.jlrunning()) .jlinit()
  res <- jleval(var)
  return(res)
}

jlvalue_set <- function(var, value, vector = FALSE) {
  if (!.jlrunning()) .jlinit()
  jlval <- jlvalue(value)
  .External("Rulia_set_global_variable", var, jlval, PACKAGE = "Rulia")
  return(invisible())
}

# jltrycall safe version of jlvalue_call

jlcall <- jltrycall <- function(meth, ..., parent_envir =  parent.frame()) {
  args <- jl_args_rexprs(substitute(list(...)), parent_envir)
  ## print(list(jltcargs=args, call=match.call(), s = substitute(list(...)),env=ls(parent_envir)))
  nmargs <- names(args)
  if(is.null(nmargs)) nmargs <- rep("",length(args))
  kwargs <- args[nmargs != ""]
  args <- args[nmargs == ""]
  ## print(list(args=args, kwargs=kwargs))
  ## print(lapply(args, jl))
  ## print(.RNamedList2jlNamedTuple(kwargs))
  jlval <- .jlvalue_trycall(jlvalue(meth), jl(lapply(args, jl)), .RNamedList2jlNamedTuple(kwargs))
  jlvalue_with_exception(match.call(), jlval)
}

jlfunc <- jltryfunc <- function(jlval_meth, ..., parent_envir =  parent.frame()) {
  args <- jl_args_rexprs(substitute(list(...)), parent_envir)
  ## print(list(jltcargs=args, call=match.call(), s = substitute(list(...)),env=ls(parent_envir)))
  nmargs <- names(args)
  if(is.null(nmargs)) nmargs <- rep("",length(args))
  kwargs <- args[nmargs != ""]
  args <- args[nmargs == ""]
  ## print(list(args=args, kwargs=kwargs))
  ## print(lapply(args, jl))
  ## print(.RNamedList2jlNamedTuple(kwargs))
  jlval <- .jlvalue_tryfunc(jlval_meth, jl(lapply(args, jl)), .RNamedList2jlNamedTuple(kwargs))
  jlvalue_with_exception(match.call(), jlval)
}

jlcallR <- jltrycallR <- function(meth, ...) toR(jltrycall(meth, ...))
jlfuncR <- jltryfuncR <- function(jlval_meth, ...) toR(jltryfunc(jlval_meth, ...))

# apply a method call 
jlvalue_call <- function(meth , ...) {
    args <- list(...)
    if (!is.character(meth)) {
        error("No julia method specified!")
    }
    if (length(args) > 3) {
      .jlvalue_call(meth, ...)
    } else {
      switch(length(args) + 1,
          .jlvalue_call0(meth),
          .jlvalue_call1(meth, ...),
          .jlvalue_call2(meth, ...),
          .jlvalue_call3(meth, ...),
          "Supposed to be done..."
      )
    }
}

jlvalue_callR <- function(meth , ...) toR(jlvalue_call(meth, ...))